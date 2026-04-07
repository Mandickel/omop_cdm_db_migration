
USE [$(DBNAME)];
GO

--sql server CDM Primary Key Constraints for OMOP Common Data Model 5.4
ALTER TABLE [$(SCHEMA)].person ADD CONSTRAINT xpk_person PRIMARY KEY NONCLUSTERED (person_id);
ALTER TABLE [$(SCHEMA)].observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY NONCLUSTERED (observation_period_id);
ALTER TABLE [$(SCHEMA)].visit_occurrence ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY NONCLUSTERED (visit_occurrence_id);
ALTER TABLE [$(SCHEMA)].visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY NONCLUSTERED (visit_detail_id);
ALTER TABLE [$(SCHEMA)].condition_occurrence ADD CONSTRAINT xpk_condition_occurrence PRIMARY KEY NONCLUSTERED (condition_occurrence_id);
ALTER TABLE [$(SCHEMA)].drug_exposure ADD CONSTRAINT xpk_drug_exposure PRIMARY KEY NONCLUSTERED (drug_exposure_id);
ALTER TABLE [$(SCHEMA)].procedure_occurrence ADD CONSTRAINT xpk_procedure_occurrence PRIMARY KEY NONCLUSTERED (procedure_occurrence_id);
ALTER TABLE [$(SCHEMA)].device_exposure ADD CONSTRAINT xpk_device_exposure PRIMARY KEY NONCLUSTERED (device_exposure_id);
ALTER TABLE [$(SCHEMA)].measurement ADD CONSTRAINT xpk_measurement PRIMARY KEY NONCLUSTERED (measurement_id);
ALTER TABLE [$(SCHEMA)].observation ADD CONSTRAINT xpk_observation PRIMARY KEY NONCLUSTERED (observation_id);
ALTER TABLE [$(SCHEMA)].note ADD CONSTRAINT xpk_note PRIMARY KEY NONCLUSTERED (note_id);
ALTER TABLE [$(SCHEMA)].note_nlp ADD CONSTRAINT xpk_note_nlp PRIMARY KEY NONCLUSTERED (note_nlp_id);
ALTER TABLE [$(SCHEMA)].specimen ADD CONSTRAINT xpk_specimen PRIMARY KEY NONCLUSTERED (specimen_id);
ALTER TABLE [$(SCHEMA)].location ADD CONSTRAINT xpk_location PRIMARY KEY NONCLUSTERED (location_id);
ALTER TABLE [$(SCHEMA)].care_site ADD CONSTRAINT xpk_care_site PRIMARY KEY NONCLUSTERED (care_site_id);
ALTER TABLE [$(SCHEMA)].provider ADD CONSTRAINT xpk_provider PRIMARY KEY NONCLUSTERED (provider_id);
ALTER TABLE [$(SCHEMA)].payer_plan_period ADD CONSTRAINT xpk_payer_plan_period PRIMARY KEY NONCLUSTERED (payer_plan_period_id);
ALTER TABLE [$(SCHEMA)].cost ADD CONSTRAINT xpk_cost PRIMARY KEY NONCLUSTERED (cost_id);
ALTER TABLE [$(SCHEMA)].drug_era ADD CONSTRAINT xpk_drug_era PRIMARY KEY NONCLUSTERED (drug_era_id);
ALTER TABLE [$(SCHEMA)].dose_era ADD CONSTRAINT xpk_dose_era PRIMARY KEY NONCLUSTERED (dose_era_id);
ALTER TABLE [$(SCHEMA)].condition_era ADD CONSTRAINT xpk_condition_era PRIMARY KEY NONCLUSTERED (condition_era_id);
ALTER TABLE [$(SCHEMA)].episode ADD CONSTRAINT xpk_episode PRIMARY KEY NONCLUSTERED (episode_id);
ALTER TABLE [$(SCHEMA)].metadata ADD CONSTRAINT xpk_metadata PRIMARY KEY NONCLUSTERED (metadata_id);
ALTER TABLE [$(SCHEMA)].concept ADD CONSTRAINT xpk_concept PRIMARY KEY NONCLUSTERED (concept_id);
ALTER TABLE [$(SCHEMA)].vocabulary ADD CONSTRAINT xpk_vocabulary PRIMARY KEY NONCLUSTERED (vocabulary_id);
ALTER TABLE [$(SCHEMA)].domain ADD CONSTRAINT xpk_domain PRIMARY KEY NONCLUSTERED (domain_id);
ALTER TABLE [$(SCHEMA)].concept_class ADD CONSTRAINT xpk_concept_class PRIMARY KEY NONCLUSTERED (concept_class_id);
ALTER TABLE [$(SCHEMA)].relationship ADD CONSTRAINT xpk_relationship PRIMARY KEY NONCLUSTERED (relationship_id);

/*sql server OMOP CDM Indices
  There are no unique indices created because it is assumed that the primary key constraints have been run prior to
  implementing indices.
*/
/************************
Standardized clinical data
************************/
CREATE CLUSTERED INDEX idx_person_id ON [$(SCHEMA)].person (person_id ASC);
CREATE INDEX idx_gender ON [$(SCHEMA)].person (gender_concept_id ASC);
CREATE CLUSTERED INDEX idx_observation_period_id_1 ON [$(SCHEMA)].observation_period (person_id ASC);
CREATE CLUSTERED INDEX idx_visit_person_id_1 ON [$(SCHEMA)].visit_occurrence (person_id ASC);
CREATE INDEX idx_visit_concept_id_1 ON [$(SCHEMA)].visit_occurrence (visit_concept_id ASC);
CREATE CLUSTERED INDEX idx_visit_det_person_id_1 ON [$(SCHEMA)].visit_detail (person_id ASC);
CREATE INDEX idx_visit_det_concept_id_1 ON [$(SCHEMA)].visit_detail (visit_detail_concept_id ASC);
CREATE INDEX idx_visit_det_occ_id ON [$(SCHEMA)].visit_detail (visit_occurrence_id ASC);
CREATE CLUSTERED INDEX idx_condition_person_id_1 ON [$(SCHEMA)].condition_occurrence (person_id ASC);
CREATE INDEX idx_condition_concept_id_1 ON [$(SCHEMA)].condition_occurrence (condition_concept_id ASC);
CREATE INDEX idx_condition_visit_id_1 ON [$(SCHEMA)].condition_occurrence (visit_occurrence_id ASC);
CREATE CLUSTERED INDEX idx_drug_person_id_1 ON [$(SCHEMA)].drug_exposure (person_id ASC);
CREATE INDEX idx_drug_concept_id_1 ON [$(SCHEMA)].drug_exposure (drug_concept_id ASC);
CREATE INDEX idx_drug_visit_id_1 ON [$(SCHEMA)].drug_exposure (visit_occurrence_id ASC);
CREATE CLUSTERED INDEX idx_procedure_person_id_1 ON [$(SCHEMA)].procedure_occurrence (person_id ASC);
CREATE INDEX idx_procedure_concept_id_1 ON [$(SCHEMA)].procedure_occurrence (procedure_concept_id ASC);
CREATE INDEX idx_procedure_visit_id_1 ON [$(SCHEMA)].procedure_occurrence (visit_occurrence_id ASC);
CREATE CLUSTERED INDEX idx_device_person_id_1 ON [$(SCHEMA)].device_exposure (person_id ASC);
CREATE INDEX idx_device_concept_id_1 ON [$(SCHEMA)].device_exposure (device_concept_id ASC);
CREATE INDEX idx_device_visit_id_1 ON [$(SCHEMA)].device_exposure (visit_occurrence_id ASC);
CREATE CLUSTERED INDEX idx_measurement_person_id_1 ON [$(SCHEMA)].measurement (person_id ASC);
CREATE INDEX idx_measurement_concept_id_1 ON [$(SCHEMA)].measurement (measurement_concept_id ASC);
CREATE INDEX idx_measurement_visit_id_1 ON [$(SCHEMA)].measurement (visit_occurrence_id ASC);
CREATE CLUSTERED INDEX idx_observation_person_id_1 ON [$(SCHEMA)].observation (person_id ASC);
CREATE INDEX idx_observation_concept_id_1 ON [$(SCHEMA)].observation (observation_concept_id ASC);
CREATE INDEX idx_observation_visit_id_1 ON [$(SCHEMA)].observation (visit_occurrence_id ASC);
CREATE CLUSTERED INDEX idx_death_person_id_1 ON [$(SCHEMA)].death (person_id ASC);
CREATE CLUSTERED INDEX idx_note_person_id_1 ON [$(SCHEMA)].note (person_id ASC);
CREATE INDEX idx_note_concept_id_1 ON [$(SCHEMA)].note (note_type_concept_id ASC);
CREATE INDEX idx_note_visit_id_1 ON [$(SCHEMA)].note (visit_occurrence_id ASC);
CREATE CLUSTERED INDEX idx_note_nlp_note_id_1 ON [$(SCHEMA)].note_nlp (note_id ASC);
CREATE INDEX idx_note_nlp_concept_id_1 ON [$(SCHEMA)].note_nlp (note_nlp_concept_id ASC);
CREATE CLUSTERED INDEX idx_specimen_person_id_1 ON [$(SCHEMA)].specimen (person_id ASC);
CREATE INDEX idx_specimen_concept_id_1 ON [$(SCHEMA)].specimen (specimen_concept_id ASC);
CREATE INDEX idx_fact_relationship_id1 ON [$(SCHEMA)].fact_relationship (domain_concept_id_1 ASC);
CREATE INDEX idx_fact_relationship_id2 ON [$(SCHEMA)].fact_relationship (domain_concept_id_2 ASC);
CREATE INDEX idx_fact_relationship_id3 ON [$(SCHEMA)].fact_relationship (relationship_concept_id ASC);


/************************
Standardized health system data
************************/
CREATE CLUSTERED INDEX idx_location_id_1 ON [$(SCHEMA)].location (location_id ASC);
CREATE CLUSTERED INDEX idx_care_site_id_1 ON [$(SCHEMA)].care_site (care_site_id ASC);
CREATE CLUSTERED INDEX idx_provider_id_1 ON [$(SCHEMA)].provider (provider_id ASC);
/************************
Standardized health economics
************************/
CREATE CLUSTERED INDEX idx_period_person_id_1 ON [$(SCHEMA)].payer_plan_period (person_id ASC);
CREATE INDEX idx_cost_event_id  ON [$(SCHEMA)].cost (cost_event_id ASC);
/************************
Standardized derived elements
************************/
CREATE CLUSTERED INDEX idx_drug_era_person_id_1 ON [$(SCHEMA)].drug_era (person_id ASC);
CREATE INDEX idx_drug_era_concept_id_1 ON [$(SCHEMA)].drug_era (drug_concept_id ASC);
CREATE CLUSTERED INDEX idx_dose_era_person_id_1 ON [$(SCHEMA)].dose_era (person_id ASC);
CREATE INDEX idx_dose_era_concept_id_1 ON [$(SCHEMA)].dose_era (drug_concept_id ASC);
CREATE CLUSTERED INDEX idx_condition_era_person_id_1 ON [$(SCHEMA)].condition_era (person_id ASC);
CREATE INDEX idx_condition_era_concept_id_1 ON [$(SCHEMA)].condition_era (condition_concept_id ASC);
/**************************
Standardized meta-data
***************************/
CREATE CLUSTERED INDEX idx_metadata_concept_id_1 ON [$(SCHEMA)].metadata (metadata_concept_id ASC);
/**************************
Standardized vocabularies
***************************/
CREATE CLUSTERED INDEX idx_concept_concept_id ON [$(SCHEMA)].concept (concept_id ASC);
CREATE INDEX idx_concept_code ON [$(SCHEMA)].concept (concept_code ASC);
CREATE INDEX idx_concept_vocabluary_id ON [$(SCHEMA)].concept (vocabulary_id ASC);
CREATE INDEX idx_concept_domain_id ON [$(SCHEMA)].concept (domain_id ASC);
CREATE INDEX idx_concept_class_id ON [$(SCHEMA)].concept (concept_class_id ASC);
CREATE CLUSTERED INDEX idx_vocabulary_vocabulary_id ON [$(SCHEMA)].vocabulary (vocabulary_id ASC);
CREATE CLUSTERED INDEX idx_domain_domain_id ON [$(SCHEMA)].domain (domain_id ASC);
CREATE CLUSTERED INDEX idx_concept_class_class_id ON [$(SCHEMA)].concept_class (concept_class_id ASC);
CREATE CLUSTERED INDEX idx_concept_relationship_id_1 ON [$(SCHEMA)].concept_relationship (concept_id_1 ASC);
CREATE INDEX idx_concept_relationship_id_2 ON [$(SCHEMA)].concept_relationship (concept_id_2 ASC);
CREATE INDEX idx_concept_relationship_id_3 ON [$(SCHEMA)].concept_relationship (relationship_id ASC);
CREATE CLUSTERED INDEX idx_relationship_rel_id ON [$(SCHEMA)].relationship (relationship_id ASC);
CREATE CLUSTERED INDEX idx_concept_synonym_id ON [$(SCHEMA)].concept_synonym (concept_id ASC);
CREATE CLUSTERED INDEX idx_concept_ancestor_id_1 ON [$(SCHEMA)].concept_ancestor (ancestor_concept_id ASC);
CREATE INDEX idx_concept_ancestor_id_2 ON [$(SCHEMA)].concept_ancestor (descendant_concept_id ASC);
CREATE CLUSTERED INDEX idx_source_to_concept_map_3 ON [$(SCHEMA)].source_to_concept_map (target_concept_id ASC);
CREATE INDEX idx_source_to_concept_map_1 ON [$(SCHEMA)].source_to_concept_map (source_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_2 ON [$(SCHEMA)].source_to_concept_map (target_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_c ON [$(SCHEMA)].source_to_concept_map (source_code ASC);
CREATE CLUSTERED INDEX idx_drug_strength_id_1 ON [$(SCHEMA)].drug_strength (drug_concept_id ASC);
CREATE INDEX idx_drug_strength_id_2 ON [$(SCHEMA)].drug_strength (ingredient_concept_id ASC);

--Additional v6.0 indices
--CREATE CLUSTERED INDEX idx_survey_person_id_1 ON [$(SCHEMA)].survey_conduct (person_id ASC);
--CREATE CLUSTERED INDEX idx_episode_person_id_1 ON [$(SCHEMA)].episode (person_id ASC);
--CREATE INDEX idx_episode_concept_id_1 ON [$(SCHEMA)].episode (episode_concept_id ASC);
--CREATE CLUSTERED INDEX idx_episode_event_id_1 ON [$(SCHEMA)].episode_event (episode_id ASC);
--CREATE INDEX idx_ee_field_concept_id_1 ON [$(SCHEMA)].episode_event (event_field_concept_id ASC);