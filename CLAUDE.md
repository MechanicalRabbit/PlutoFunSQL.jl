# CLAUDE.md

This is the memory file for Claude Code (claude.ai/code).

## Project Overview

This project demonstrates the use of FunSQL.jl in the context of biomedical research, specifically the data transformation from an Electronic Health Records system to OHDSI's OMOP data model. FunSQL has a native Julia syntax, and a macro syntax via @funsql. Generally, we use the @funsql syntax for this project.

The work is primarily done in Julia Pluto notebooks. These are julia program files using comments to indicate each cell in the notebook and cell order. When using a notebook, there are other nuances such as disabling of cells and use of UUIDs to manage.

## Architecture Overview

PlutoFunSQL.jl is a FunSQL IDE built on Julia's Pluto notebook system. It provides an interactive environment for exploring databases using FunSQL query combinators.

### Core Components

**Main Module** (`src/PlutoFunSQL.jl`):
- Exports FunSQL functionality enhanced for Pluto notebooks
- Includes all submodules in specific order, with `duckdb.jl` last to export all `funsql_*` functions

**Query System** (`src/query.jl`):
- `@query` macro for executing FunSQL queries against databases
- Takes database connection and FunSQL query, returns DataFrame
- Uses FunSQL's transliteration system to convert query syntax

**Database Integration** (`src/duckdb.jl`):
- DuckDB-specific functionality and aggregate function definitions
- Maintains comprehensive list of DuckDB aggregate functions since they're not exposed in `duckdb_functions()`
- Exports FunSQL functions with `funsql_` prefix

**Custom Resolution** (`src/resolve.jl`):
- `CustomResolve` combinator for transforming FunSQL nodes
- Provides hooks for custom query transformation logic

**Summary Generation** (`src/summary.jl`):
- Table summarization functionality for data exploration

**Inventory Utilities** (`src/inventory.jl`):
- Primary and foreign key validation tools

### Notebook Structure

Notebooks in `examples/` show use for transformations and analysis:

- `explore-eicu.jl` - Exploration of eICU database
- `explore-mimic.jl` - Exploration of MIMIC database
- `mimic_catalog.jl` - Catalog objects for MIMIC database

### MIMIC-IV Database Structure

MIMIC-IV is a critical care database containing real hospital stays from a tertiary academic medical center. The database is organized into five modules reflecting data provenance:

**Module Overview**:
- **hosp**: Hospital-wide EHR data (labs, medications, billing, demographics) - foundational module containing all patients
- **icu**: ICU-specific clinical data from MetaVision system (vital signs, medications, procedures, charted events)
- **ed**: Emergency department data (triage, vitals, diagnoses, medication reconciliation)
- **cxr**: Chest X-ray metadata linking to MIMIC-CXR imaging dataset
- **note**: Deidentified clinical notes (currently not publicly available)

**Key Identifier System**:
- `subject_id`: Unique patient identifier across all modules
- `hadm_id`: Unique hospital admission identifier
- `stay_id`: Unique ward/ICU stay identifier (groups contiguous episodes within 24 hours)
- `transfer_id`: Individual room/ward transfer identifier

**Critical Tables by Module**:

*Hosp Module (Hospital-wide)*:
- `patients`: Demographics, anchor age/year for temporal analysis, death dates
- `admissions`: Hospital stays with admission/discharge times, demographics, insurance
- `transfers`: Patient movements between hospital locations and wards
- `labevents`: Laboratory measurements linked to `d_labitems` for concept definitions
- `microbiologyevents`: Culture results and antimicrobial sensitivities
- `prescriptions`: Medication orders and `emar`/`emar_detail`: Electronic medication administration
- `diagnoses_icd`/`procedures_icd`: Billing codes linked to ICD definition tables

*ICU Module (Intensive Care)*:
- `icustays`: ICU episode tracking with care unit information and length of stay
- `chartevents`: Primary repository of ICU charted data (vital signs, assessments, settings)
- `inputevents`: IV fluids, medications, nutrition with start/end times
- `outputevents`: Patient outputs (urine, drains, etc.)
- `procedureevents`: ICU procedures and interventions
- `d_items`: Concept definitions for all itemid values in ICU event tables

*ED Module (Emergency Department)*:
- `edstays`: ED episode tracking with arrival transport and disposition
- `triage`: Initial assessment and acuity scores
- `vitalsign`: ED vital sign measurements
- `diagnosis`: ED diagnoses and chief complaints

**Temporal Concepts**:
- `charttime`: Time of clinical observation/measurement (primary temporal reference)
- `storetime`: Time of data validation/entry into system
- Date shifting: All dates shifted for privacy while maintaining internal consistency
- `anchor_year`/`anchor_age`: Reference points for temporal analysis across patients

**Data Linkage Patterns**:
- Not all patients appear in all modules (ICU ⊂ hospital, ED ∩ hospital ≠ ∅)
- `subject_id` links across all modules
- `hadm_id` links hospital admissions to ICU stays and some ED visits
- Laboratory data may exist both in `labevents` (authoritative) and `chartevents` (display copy)

### OHDSI Community MIMIC-IV to OMOP ETL Implementation

The `context/MIMIC` repository contains the official OHDSI community ETL for converting MIMIC-IV PhysioNet datasets into OMOP CDM v5.3.1 format. This production-grade implementation by Odysseus Data Services provides comprehensive patterns for biomedical data transformation.

**ETL Architecture (5-Stage Pipeline)**:
- **Staging**: Source data snapshots with complete traceability metadata
- **Cleaning**: Data filtering and formatting into intermediate `lk_` tables
- **Concept Mapping**: Source code mapping to OMOP vocabulary concepts
- **Data Integration**: Joining cleaned data with mapped concepts
- **Distribution**: Population of target CDM tables based on domain routing

**Key Technical Patterns**:
- **Platform**: BigQuery-native SQL with Python orchestration
- **ID Management**: UUID-based synthetic identifier generation for privacy compliance
- **Vocabulary Strategy**: 27 custom vocabularies (2B+ concept ID range) with standard concept fallbacks
- **Multi-Source Integration**: Complex domain routing (Person, Visit, Condition, Drug, Measurement)

**Domain-Specific Transformations**:
- **Person**: Ethnicity resolution via window functions, demographic standardization
- **Visit Occurrence**: Composite identifiers with preceding visit linkage
- **Condition**: Multi-source strategy (diagnoses\_icd, chartevents value/item-based)
- **Measurement**: 10+ transformation rules covering labs, vitals, microbiology, outputs
- **Drug Exposure**: Simplified single-source approach with pharmacy prioritization

**Advanced Features**:
- Complete data lineage tracking with `unit_id`, `load_table_id`, `load_row_id`, `trace_id`
- Automated quality assurance with unit testing and mapping rate analysis
- Scalable workflow orchestration with incremental processing capabilities
- Atlas-ready dataset generation for OHDSI tool integration

This implementation serves as the definitive reference for MIMIC-IV to OMOP conversion, providing battle-tested patterns for complex EHR data transformation while maintaining OMOP CDM compliance.

### Reference Repositories

**Context Dependencies** (`context/` directory):
- **FunSQL.jl**: Core query combinator library providing compositional SQL construction
- **FunSQL-TestData**: Standardized test datasets (MIMIC-IV demo, eICU-CRD demo) packaged as Julia artifacts for biomedical research demonstrations
- **mimic-website**: MIMIC documentation website (only `content/en/docs/IV` needed for MIMIC-IV database structure reference)
- **MIMIC**: OHDSI community MIMIC-IV to OMOP ETL implementation and mapping resources

### Dependencies

Key dependencies for understanding the codebase:
- FunSQL.jl: Core query combinator library
- Pluto.jl: Notebook environment
- DuckDB.jl: Database backend
- HypertextLiteral.jl: HTML generation for notebook display
