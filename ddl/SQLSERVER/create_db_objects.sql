-- ============================================
-- Ensure database exists before using it
-- ============================================
IF DB_ID('$(DBNAME)') IS NULL
BEGIN
    PRINT 'Database $(DBNAME) does not exist. Creating...';
    DECLARE @sql NVARCHAR(MAX) = N'CREATE DATABASE [' + '$(DBNAME)' + N']';
    EXEC(@sql);
END
GO

USE [$(DBNAME)];
GO
--sql server CDM DDL Specification for OMOP Common Data Model 5.4

--CREATE CDM TABLE person
CREATE TABLE [$(SCHEMA)].person (
			person_id BIGINT NOT NULL,
			gender_concept_id BIGINT NOT NULL,
			year_of_birth BIGINT NOT NULL,
			month_of_birth BIGINT NULL,
			day_of_birth BIGINT NULL,
			birth_datetime datetime NULL,
			race_concept_id BIGINT NOT NULL,
			ethnicity_concept_id BIGINT NOT NULL,
			location_id BIGINT NULL,
			provider_id BIGINT NULL,
			care_site_id BIGINT NULL,
			person_source_value varchar(50) NULL,
			gender_source_value varchar(50) NULL,
			gender_source_concept_id BIGINT NULL,
			race_source_value varchar(50) NULL,
			race_source_concept_id BIGINT NULL,
			ethnicity_source_value varchar(50) NULL,
			ethnicity_source_concept_id BIGINT NULL );
--CREATE CDM TABLE observation_period
CREATE TABLE [$(SCHEMA)].observation_period (
			observation_period_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			observation_period_start_date date NOT NULL,
			observation_period_end_date date NOT NULL,
			period_type_concept_id BIGINT NOT NULL );
--CREATE CDM TABLE visit_occurrence
CREATE TABLE [$(SCHEMA)].visit_occurrence (
			visit_occurrence_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			visit_concept_id BIGINT NOT NULL,
			visit_start_date date NOT NULL,
			visit_start_datetime datetime NULL,
			visit_end_date date NOT NULL,
			visit_end_datetime datetime NULL,
			visit_type_concept_id BIGINT NOT NULL,
			provider_id BIGINT NULL,
			care_site_id BIGINT NULL,
			visit_source_value varchar(50) NULL,
			visit_source_concept_id BIGINT NULL,
			admitted_from_concept_id BIGINT NULL,
			admitted_from_source_value varchar(50) NULL,
			discharged_to_concept_id BIGINT NULL,
			discharged_to_source_value varchar(50) NULL,
			preceding_visit_occurrence_id BIGINT NULL );
--CREATE CDM TABLE visit_detail
CREATE TABLE [$(SCHEMA)].visit_detail (
			visit_detail_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			visit_detail_concept_id BIGINT NOT NULL,
			visit_detail_start_date date NOT NULL,
			visit_detail_start_datetime datetime NULL,
			visit_detail_end_date date NOT NULL,
			visit_detail_end_datetime datetime NULL,
			visit_detail_type_concept_id BIGINT NOT NULL,
			provider_id BIGINT NULL,
			care_site_id BIGINT NULL,
			visit_detail_source_value varchar(50) NULL,
			visit_detail_source_concept_id BIGINT NULL,
			admitted_from_concept_id BIGINT NULL,
			admitted_from_source_value varchar(50) NULL,
			discharged_to_source_value varchar(50) NULL,
			discharged_to_concept_id BIGINT NULL,
			preceding_visit_detail_id BIGINT NULL,
			parent_visit_detail_id BIGINT NULL,
			visit_occurrence_id BIGINT NOT NULL );
--CREATE CDM TABLE  condition_occurrence
CREATE TABLE [$(SCHEMA)].condition_occurrence (
			condition_occurrence_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			condition_concept_id BIGINT NOT NULL,
			condition_start_date date NOT NULL,
			condition_start_datetime datetime NULL,
			condition_end_date date NULL,
			condition_end_datetime datetime NULL,
			condition_type_concept_id BIGINT NOT NULL,
			condition_status_concept_id BIGINT NULL,
			stop_reason varchar(20) NULL,
			provider_id BIGINT NULL,
			visit_occurrence_id BIGINT NULL,
			visit_detail_id BIGINT NULL,
			condition_source_value varchar(255) NULL,
			condition_source_concept_id BIGINT NULL,
			condition_status_source_value varchar(50) NULL );
--CREATE CDM TABLE drug_exposure
CREATE TABLE [$(SCHEMA)].drug_exposure (
			drug_exposure_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			drug_concept_id BIGINT NOT NULL,
			drug_exposure_start_date date NOT NULL,
			drug_exposure_start_datetime datetime NULL,
			drug_exposure_end_date date NOT NULL,
			drug_exposure_end_datetime datetime NULL,
			verbatim_end_date date NULL,
			drug_type_concept_id BIGINT NOT NULL,
			stop_reason varchar(20) NULL,
			refills BIGINT NULL,
			quantity float NULL,
			days_supply BIGINT NULL,
			sig varchar(MAX) NULL,
			route_concept_id BIGINT NULL,
			lot_number varchar(50) NULL,
			provider_id BIGINT NULL,
			visit_occurrence_id BIGINT NULL,
			visit_detail_id BIGINT NULL,
			drug_source_value varchar(50) NULL,
			drug_source_concept_id BIGINT NULL,
			route_source_value varchar(255) NULL,
			dose_unit_source_value varchar(50) NULL );
--CREATE CDM TABLE procedure_occurrence
CREATE TABLE [$(SCHEMA)].procedure_occurrence (
			procedure_occurrence_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			procedure_concept_id BIGINT NOT NULL,
			procedure_date date NOT NULL,
			procedure_datetime datetime NULL,
			procedure_end_date date NULL,
			procedure_end_datetime datetime NULL,
			procedure_type_concept_id BIGINT NOT NULL,
			modifier_concept_id BIGINT NULL,
			quantity BIGINT NULL,
			provider_id BIGINT NULL,
			visit_occurrence_id BIGINT NULL,
			visit_detail_id BIGINT NULL,
			procedure_source_value varchar(50) NULL,
			procedure_source_concept_id BIGINT NULL,
			modifier_source_value varchar(50) NULL );
--CREATE CDM TABLE device_exposure
CREATE TABLE [$(SCHEMA)].device_exposure (
			device_exposure_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			device_concept_id BIGINT NOT NULL,
			device_exposure_start_date date NOT NULL,
			device_exposure_start_datetime datetime NULL,
			device_exposure_end_date date NULL,
			device_exposure_end_datetime datetime NULL,
			device_type_concept_id BIGINT NOT NULL,
			unique_device_id varchar(255) NULL,
			production_id varchar(255) NULL,
			quantity BIGINT NULL,
			provider_id BIGINT NULL,
			visit_occurrence_id BIGINT NULL,
			visit_detail_id BIGINT NULL,
			device_source_value varchar(50) NULL,
			device_source_concept_id BIGINT NULL,
			unit_concept_id BIGINT NULL,
			unit_source_value varchar(50) NULL,
			unit_source_concept_id BIGINT NULL );
--CREATE CDM TABLE measurement
CREATE TABLE [$(SCHEMA)].measurement (
			measurement_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			measurement_concept_id BIGINT NOT NULL,
			measurement_date date NOT NULL,
			measurement_datetime datetime NULL,
			measurement_time varchar(10) NULL,
			measurement_type_concept_id BIGINT NOT NULL,
			operator_concept_id BIGINT NULL,
			value_as_number float NULL,
			value_as_concept_id BIGINT NULL,
			unit_concept_id BIGINT NULL,
			range_low float NULL,
			range_high float NULL,
			provider_id BIGINT NULL,
			visit_occurrence_id BIGINT NULL,
			visit_detail_id BIGINT NULL,
			measurement_source_value varchar(255) NULL,
			measurement_source_concept_id BIGINT NULL,
			unit_source_value varchar(50) NULL,
			unit_source_concept_id BIGINT NULL,
			value_source_value varchar(50) NULL,
			measurement_event_id BIGINT NULL,
			meas_event_field_concept_id BIGINT NULL );
--CREATE CDM TABLE observation
CREATE TABLE [$(SCHEMA)].observation (
			observation_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			observation_concept_id BIGINT NOT NULL,
			observation_date date NOT NULL,
			observation_datetime datetime NULL,
			observation_type_concept_id BIGINT NOT NULL,
			value_as_number float NULL,
			value_as_string varchar(60) NULL,
			value_as_concept_id BIGINT NULL,
			qualifier_concept_id BIGINT NULL,
			unit_concept_id BIGINT NULL,
			provider_id BIGINT NULL,
			visit_occurrence_id BIGINT NULL,
			visit_detail_id BIGINT NULL,
			observation_source_value varchar(255) NULL,
			observation_source_concept_id BIGINT NULL,
			unit_source_value varchar(50) NULL,
			qualifier_source_value varchar(50) NULL,
			value_source_value varchar(50) NULL,
			observation_event_id BIGINT NULL,
			obs_event_field_concept_id BIGINT NULL );
--CREATE CDM TABLE death
CREATE TABLE [$(SCHEMA)].death (
			person_id BIGINT NOT NULL,
			death_date date NOT NULL,
			death_datetime datetime NULL,
			death_type_concept_id BIGINT NULL,
			cause_concept_id BIGINT NULL,
			cause_source_value varchar(50) NULL,
			cause_source_concept_id BIGINT NULL );
--CREATE CDM TABLE note
CREATE TABLE [$(SCHEMA)].note (
			note_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			note_date date NOT NULL,
			note_datetime datetime NULL,
			note_type_concept_id BIGINT NOT NULL,
			note_class_concept_id BIGINT NOT NULL,
			note_title varchar(250) NULL,
			note_text varchar(MAX) NOT NULL,
			encoding_concept_id BIGINT NOT NULL,
			language_concept_id BIGINT NOT NULL,
			provider_id BIGINT NULL,
			visit_occurrence_id BIGINT NULL,
			visit_detail_id BIGINT NULL,
			note_source_value varchar(50) NULL,
			note_event_id BIGINT NULL,
			note_event_field_concept_id BIGINT NULL );
--CREATE CDM TABLE note_nlp 
CREATE TABLE [$(SCHEMA)].note_nlp (
			note_nlp_id BIGINT NOT NULL,
			note_id BIGINT NOT NULL,
			section_concept_id BIGINT NULL,
			snippet varchar(250) NULL,
			[offset] varchar(50) NULL,
			lexical_variant varchar(250) NOT NULL,
			note_nlp_concept_id BIGINT NULL,
			note_nlp_source_concept_id BIGINT NULL,
			nlp_system varchar(250) NULL,
			nlp_date date NOT NULL,
			nlp_datetime datetime NULL,
			term_exists varchar(1) NULL,
			term_temporal varchar(50) NULL,
			term_modifiers varchar(2000) NULL );
--CREATE CDM TABLE specimen
CREATE TABLE [$(SCHEMA)].specimen (
			specimen_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			specimen_concept_id BIGINT NOT NULL,
			specimen_type_concept_id BIGINT NOT NULL,
			specimen_date date NOT NULL,
			specimen_datetime datetime NULL,
			quantity float NULL,
			unit_concept_id BIGINT NULL,
			anatomic_site_concept_id BIGINT NULL,
			disease_status_concept_id BIGINT NULL,
			specimen_source_id varchar(50) NULL,
			specimen_source_value varchar(50) NULL,
			unit_source_value varchar(50) NULL,
			anatomic_site_source_value varchar(50) NULL,
			disease_status_source_value varchar(50) NULL );
--CREATE CDM fact_relationship  
CREATE TABLE [$(SCHEMA)].fact_relationship (
			domain_concept_id_1 BIGINT NOT NULL,
			fact_id_1 BIGINT NOT NULL,
			domain_concept_id_2 BIGINT NOT NULL,
			fact_id_2 BIGINT NOT NULL,
			relationship_concept_id BIGINT NOT NULL );
--CREATE CDM TABLE location
CREATE TABLE [$(SCHEMA)].location (
			location_id BIGINT NOT NULL,
			address_1 varchar(50) NULL,
			address_2 varchar(50) NULL,
			city varchar(50) NULL,
			state varchar(2) NULL,
			zip varchar(9) NULL,
			county varchar(20) NULL,
			location_source_value varchar(50) NULL,
			country_concept_id BIGINT NULL,
			country_source_value varchar(80) NULL,
			latitude float NULL,
			longitude float NULL );
--CREATE CDM TABLE care_site 
CREATE TABLE [$(SCHEMA)].care_site (
			care_site_id BIGINT NOT NULL,
			care_site_name varchar(255) NULL,
			place_of_service_concept_id BIGINT NULL,
			location_id BIGINT NULL,
			care_site_source_value varchar(50) NULL,
			place_of_service_source_value varchar(50) NULL );
--CREATE CDM TABLE provider 
CREATE TABLE [$(SCHEMA)].provider (
			provider_id BIGINT NOT NULL,
			provider_name varchar(255) NULL,
			npi varchar(20) NULL,
			dea varchar(20) NULL,
			specialty_concept_id BIGINT NULL,
			care_site_id BIGINT NULL,
			year_of_birth BIGINT NULL,
			gender_concept_id BIGINT NULL,
			provider_source_value varchar(50) NULL,
			specialty_source_value varchar(50) NULL,
			specialty_source_concept_id BIGINT NULL,
			gender_source_value varchar(50) NULL,
			gender_source_concept_id BIGINT NULL );
--CREATE CDM TABLE payer_plan_period
CREATE TABLE [$(SCHEMA)].payer_plan_period (
			payer_plan_period_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			payer_plan_period_start_date date NOT NULL,
			payer_plan_period_end_date date NOT NULL,
			payer_concept_id BIGINT NULL,
			payer_source_value varchar(50) NULL,
			payer_source_concept_id BIGINT NULL,
			plan_concept_id BIGINT NULL,
			plan_source_value varchar(50) NULL,
			plan_source_concept_id BIGINT NULL,
			sponsor_concept_id BIGINT NULL,
			sponsor_source_value varchar(50) NULL,
			sponsor_source_concept_id BIGINT NULL,
			family_source_value varchar(50) NULL,
			stop_reason_concept_id BIGINT NULL,
			stop_reason_source_value varchar(50) NULL,
			stop_reason_source_concept_id BIGINT NULL );
--CREATE CDM TABLE cost 
CREATE TABLE [$(SCHEMA)].cost (
			cost_id BIGINT NOT NULL,
			cost_event_id BIGINT NOT NULL,
			cost_domain_id varchar(20) NOT NULL,
			cost_type_concept_id BIGINT NOT NULL,
			currency_concept_id BIGINT NULL,
			total_charge float NULL,
			total_cost float NULL,
			total_paid float NULL,
			paid_by_payer float NULL,
			paid_by_patient float NULL,
			paid_patient_copay float NULL,
			paid_patient_coinsurance float NULL,
			paid_patient_deductible float NULL,
			paid_by_primary float NULL,
			paid_ingredient_cost float NULL,
			paid_dispensing_fee float NULL,
			payer_plan_period_id BIGINT NULL,
			amount_allowed float NULL,
			revenue_code_concept_id BIGINT NULL,
			revenue_code_source_value varchar(50) NULL,
			drg_concept_id BIGINT NULL,
			drg_source_value varchar(3) NULL );
--CREATE CDM TABLE drug_era
CREATE TABLE [$(SCHEMA)].drug_era (
			drug_era_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			drug_concept_id BIGINT NOT NULL,
			drug_era_start_date date NOT NULL,
			drug_era_end_date date NOT NULL,
			drug_exposure_count BIGINT NULL,
			gap_days BIGINT NULL );
--CREATE CDM TABLE dose_era
CREATE TABLE [$(SCHEMA)].dose_era (
			dose_era_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			drug_concept_id BIGINT NOT NULL,
			unit_concept_id BIGINT NOT NULL,
			dose_value float NOT NULL,
			dose_era_start_date date NOT NULL,
			dose_era_end_date date NOT NULL );
--CREATE CDM TABLE condition_era
CREATE TABLE [$(SCHEMA)].condition_era (
			condition_era_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			condition_concept_id BIGINT NOT NULL,
			condition_era_start_date date NOT NULL,
			condition_era_end_date date NOT NULL,
			condition_occurrence_count BIGINT NULL );
--CREATE CDM TABLE episode
CREATE TABLE [$(SCHEMA)].episode (
			episode_id BIGINT NOT NULL,
			person_id BIGINT NOT NULL,
			episode_concept_id BIGINT NOT NULL,
			episode_start_date date NOT NULL,
			episode_start_datetime datetime NULL,
			episode_end_date date NULL,
			episode_end_datetime datetime NULL,
			episode_parent_id BIGINT NULL,
			episode_number BIGINT NULL,
			episode_object_concept_id BIGINT NOT NULL,
			episode_type_concept_id BIGINT NOT NULL,
			episode_source_value varchar(50) NULL,
			episode_source_concept_id BIGINT NULL );
--CREATE CDM TABLE episode_event
CREATE TABLE [$(SCHEMA)].episode_event (
			episode_id BIGINT NOT NULL,
			event_id BIGINT NOT NULL,
			episode_event_field_concept_id BIGINT NOT NULL );
--CREATE CDM TABLE metadata
CREATE TABLE [$(SCHEMA)].metadata (
			metadata_id BIGINT NOT NULL,
			metadata_concept_id BIGINT NOT NULL,
			metadata_type_concept_id BIGINT NOT NULL,
			name varchar(250) NOT NULL,
			value_as_string varchar(250) NULL,
			value_as_concept_id BIGINT NULL,
			value_as_number float NULL,
			metadata_date date NULL,
			metadata_datetime datetime NULL );
--CREATE CDM TABLE metadata_tmp
CREATE TABLE [$(SCHEMA)].metadata_tmp (
			person_id BIGINT NOT NULL,
			name NVARCHAR(250) NOT NULL);
--CREATE CDM TABLE cdm_source
CREATE TABLE [$(SCHEMA)].cdm_source (
			cdm_source_name varchar(255) NOT NULL,
			cdm_source_abbreviation varchar(25) NOT NULL,
			cdm_holder varchar(255) NOT NULL,
			source_description varchar(MAX) NULL,
			source_documentation_reference varchar(255) NULL,
			cdm_etl_reference varchar(255) NULL,
			source_release_date date NOT NULL,
			cdm_release_date date NOT NULL,
			cdm_version varchar(10) NULL,
			cdm_version_concept_id BIGINT NOT NULL,
			vocabulary_version varchar(20) NOT NULL );
--CREATE CDM TABLE concept
CREATE TABLE [$(SCHEMA)].concept (
			concept_id BIGINT NOT NULL,
			concept_name varchar(255) NOT NULL,
			domain_id varchar(20) NOT NULL,
			vocabulary_id varchar(20) NOT NULL,
			concept_class_id varchar(20) NOT NULL,
			standard_concept varchar(1) NULL,
			concept_code varchar(50) NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(10) NULL );		
--CREATE CDM TABLE vocabulary
CREATE TABLE [$(SCHEMA)].vocabulary (
			vocabulary_id varchar(20) NOT NULL,
			vocabulary_name varchar(255) NOT NULL,
			vocabulary_reference varchar(255) NULL,
			vocabulary_version varchar(255) NULL,
			vocabulary_concept_id BIGINT NOT NULL );
--CREATE CDM TABLE domain
CREATE TABLE [$(SCHEMA)].domain (
			domain_id varchar(20) NOT NULL,
			domain_name varchar(255) NOT NULL,
			domain_concept_id BIGINT NOT NULL );
--CREATE CDM TABLE concept_class
CREATE TABLE [$(SCHEMA)].concept_class (
			concept_class_id varchar(20) NOT NULL,
			concept_class_name varchar(255) NOT NULL,
			concept_class_concept_id BIGINT NOT NULL );
--CREATE CDM TABLE concept_relationship
CREATE TABLE [$(SCHEMA)].concept_relationship (
			concept_id_1 BIGINT NOT NULL,
			concept_id_2 BIGINT NOT NULL,
			relationship_id varchar(20) NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
--CREATE CDM TABLE relationship
CREATE TABLE [$(SCHEMA)].relationship (
			relationship_id varchar(20) NOT NULL,
			relationship_name varchar(255) NOT NULL,
			is_hierarchical varchar(1) NOT NULL,
			defines_ancestry varchar(1) NOT NULL,
			reverse_relationship_id varchar(20) NOT NULL,
			relationship_concept_id BIGINT NOT NULL );
--CREATE CDM TABLE concept_synonym
CREATE TABLE [$(SCHEMA)].concept_synonym (
			concept_id BIGINT NOT NULL,
			concept_synonym_name varchar(1000) NOT NULL,
			language_concept_id BIGINT NOT NULL );
--CREATE CDM TABLE concept_ancestor
CREATE TABLE [$(SCHEMA)].concept_ancestor (
			ancestor_concept_id BIGINT NOT NULL,
			descendant_concept_id BIGINT NOT NULL,
			min_levels_of_separation BIGINT NOT NULL,
			max_levels_of_separation BIGINT NOT NULL );
--CREATE CDM TABLE source_to_concept_map
CREATE TABLE [$(SCHEMA)].source_to_concept_map (
			source_code varchar(255) NOT NULL,
			source_concept_id BIGINT NOT NULL,
			source_vocabulary_id varchar(20) NOT NULL,
			source_code_description varchar(255) NULL,
			target_concept_id BIGINT NOT NULL,
			target_vocabulary_id varchar(20) NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
--CREATE CDM TABLE drug_strength
CREATE TABLE [$(SCHEMA)].drug_strength (
			drug_concept_id BIGINT NOT NULL,
			ingredient_concept_id BIGINT NOT NULL,
			amount_value float NULL,
			amount_unit_concept_id BIGINT NULL,
			numerator_value float NULL,
			numerator_unit_concept_id BIGINT NULL,
			denominator_value float NULL,
			denominator_unit_concept_id BIGINT NULL,
			box_size BIGINT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
--CREATE CDM TABLE cohort
CREATE TABLE [$(SCHEMA)].cohort (
			cohort_definition_id BIGINT NOT NULL,
			subject_id BIGINT NOT NULL,
			cohort_start_date date NOT NULL,
			cohort_end_date date NOT NULL );
--CREATE CDM TABLE cohort_definition
CREATE TABLE [$(SCHEMA)].cohort_definition (
			cohort_definition_id BIGINT NOT NULL,
			cohort_definition_name varchar(255) NOT NULL,
			cohort_definition_description varchar(MAX) NULL,
			definition_type_concept_id BIGINT NOT NULL,
			cohort_definition_syntax varchar(MAX) NULL,
			subject_concept_id BIGINT NOT NULL,
			cohort_initiation_date date NULL );
--CREATE CDM TABLE source_to_source_vocab_map
CREATE TABLE [$(SCHEMA)].source_to_source_vocab_map (
			source_code varchar(500),
			source_concept_id BIGINT,
			source_code_description varchar(300),--500 for UKBB
			source_vocabulary_id varchar(30),
			source_domain_id varchar(20),
			source_concept_class_id varchar(20),
			source_valid_start_date date,
			source_valid_end_date date,
			source_invalid_reason varchar(1),
			target_concept_id BIGINT,
			target_concept_name varchar(300),--500 for UKBB
			target_vocabulary_id varchar(30),
			target_domain_id varchar(20),
			target_concept_class_id varchar(20),
			target_invalid_reason varchar(1),
			target_standard_concept varchar(1)
);
--CREATE CDM TABLE source_to_source_vocab_map
CREATE TABLE [$(SCHEMA)].source_to_standard_vocab_map(
			source_code varchar(500) NOT NULL,
			source_concept_id BIGINT,
			source_code_description varchar(500),
			source_vocabulary_id varchar(30) NOT NULL,
			source_domain_id varchar(20),
			source_concept_class_id varchar(20),
			source_valid_start_date date,
			source_valid_end_date date,
			source_invalid_reason varchar(1),
			target_concept_id BIGINT NOT NULL,
			target_concept_name varchar(500),
			target_vocabulary_id varchar(30),
			target_domain_id varchar(20),
			target_concept_class_id varchar(20),
			target_invalid_reason varchar(1),
			target_standard_concept varchar(1)
);
--CREATE CDM TABLE _records
CREATE TABLE [$(SCHEMA)].[_records] (
			tbl_name varchar(25) NOT NULL,
			total_records BIGINT NOT NULL);
--CREATE CDM TABLE _records
CREATE TABLE [$(SCHEMA)].[_max_ids] (
			tbl_name varchar(25) NOT NULL,
			total_records BIGINT NOT NULL);