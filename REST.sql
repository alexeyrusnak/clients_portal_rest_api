set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2016.08.24'
,p_default_workspace_id=>1654846481149294
);
end;
/
prompt  WORKSPACE 1654846481149294
--
-- Workspace, User Group, User, and Team Development Export:
--   Date and Time:   15:47 Monday April 30, 2018
--   Exported By:     ADMIN
--   Export Type:     Workspace Export
--   Version:         5.1.0.00.45
--   Instance ID:     102251900523269
--
-- Import:
--   Using Instance Administration / Manage Workspaces
--   or
--   Using SQL*Plus as the Oracle user APEX_050100
 
begin
    wwv_flow_api.set_security_group_id(p_security_group_id=>1654846481149294);
end;
/
----------------
-- W O R K S P A C E
-- Creating a workspace will not create database schemas or objects.
-- This API creates only the meta data for this APEX workspace
prompt  Creating workspace REST...
begin
wwv_flow_fnd_user_api.create_company (
  p_id => 1655099576149371
 ,p_provisioning_company_id => 1654846481149294
 ,p_short_name => 'REST'
 ,p_display_name => 'REST'
 ,p_first_schema_provisioned => 'REST'
 ,p_company_schemas => 'REST'
 ,p_ws_schema => 'REST'
 ,p_account_status => 'ASSIGNED'
 ,p_allow_plsql_editing => 'Y'
 ,p_allow_app_building_yn => 'Y'
 ,p_allow_packaged_app_ins_yn => 'Y'
 ,p_allow_sql_workshop_yn => 'Y'
 ,p_allow_websheet_dev_yn => 'Y'
 ,p_allow_team_development_yn => 'Y'
 ,p_allow_to_be_purged_yn => 'Y'
 ,p_allow_restful_services_yn => 'Y'
 ,p_source_identifier => 'REST'
 ,p_path_prefix => 'REST'
 ,p_files_version => 1
);
end;
/
----------------
-- G R O U P S
--
prompt  Creating Groups...
begin
wwv_flow_fnd_user_api.create_user_group (
  p_id => 5740767839632071,
  p_GROUP_NAME => 'Администраторы',
  p_SECURITY_GROUP_ID => 1654846481149294,
  p_GROUP_DESC => '');
end;
/
begin
wwv_flow_fnd_user_api.create_user_group (
  p_id => 5740894262635768,
  p_GROUP_NAME => 'Пользователи',
  p_SECURITY_GROUP_ID => 1654846481149294,
  p_GROUP_DESC => '');
end;
/
begin
wwv_flow_fnd_user_api.create_user_group (
  p_id => 5741938931691589,
  p_GROUP_NAME => 'Пользователи расш.',
  p_SECURITY_GROUP_ID => 1654846481149294,
  p_GROUP_DESC => '');
end;
/
begin
wwv_flow_api.create_user_groups (
  p_id => 1653604754130823,
  p_GROUP_NAME => 'OAuth2 Client Developer',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to register OAuth2 Client Applications');
end;
/
begin
wwv_flow_api.create_user_groups (
  p_id => 1653552153130823,
  p_GROUP_NAME => 'RESTful Services',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to use RESTful Services with this workspace');
end;
/
begin
wwv_flow_api.create_user_groups (
  p_id => 1653425778130823,
  p_GROUP_NAME => 'SQL Developer',
  p_SECURITY_GROUP_ID => 10,
  p_GROUP_DESC => 'Users authorized to use SQL Developer with this workspace');
end;
/
prompt  Creating group grants...
begin
wwv_flow_fnd_user_api.set_group_group_grants (
  p_group_id => 5740767839632071
, p_granted_group_ids => wwv_flow_t_number(1653425778130823
                       , 1653552153130823
                       , 1653604754130823
                       , 5740894262635768
));
end;
/
begin
wwv_flow_fnd_user_api.set_group_group_grants (
  p_group_id => 5740894262635768
, p_granted_group_ids => wwv_flow_t_number(1653552153130823
));
end;
/
begin
wwv_flow_fnd_user_api.set_group_group_grants (
  p_group_id => 5741938931691589
, p_granted_group_ids => wwv_flow_t_number(1653552153130823
));
end;
/
----------------
-- U S E R S
-- User repository for use with APEX cookie-based authentication.
--
prompt  Creating Users...
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '1654741893149294',
  p_user_name                    => 'ADMIN',
  p_first_name                   => '',
  p_last_name                    => '',
  p_description                  => '',
  p_email_address                => 'x@x.ru',
  p_web_password                 => 'E63D55F6D8D1F859DE908F2926CCB800ACBA7397',
  p_web_password_format          => '5;2;10000',
  p_group_ids                    => '5740767839632071:',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'REST',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201804031533','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'N',
  p_first_password_use_occurred  => 'Y',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '2031208126817828',
  p_user_name                    => 'LUTIK',
  p_first_name                   => 'Петр',
  p_last_name                    => 'Сидоров',
  p_description                  => '',
  p_email_address                => 'test@mail.ru',
  p_web_password                 => '2EC5A32D340B7F79C5AC1ACBB8AFBDD9625D4252',
  p_web_password_format          => '5;2;10000',
  p_group_ids                    => '5740894262635768:',
  p_developer_privs              => '',
  p_default_schema               => 'REST',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201710201358','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 1,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'N',
  p_allow_sql_workshop_yn        => 'N',
  p_allow_websheet_dev_yn        => 'N',
  p_allow_team_development_yn    => 'N',
  p_attribute_01                 => '17318',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '5261266019161941',
  p_user_name                    => 'REST',
  p_first_name                   => 'Иван',
  p_last_name                    => 'Иванов',
  p_description                  => '',
  p_email_address                => 'servicedesk@mobilesol.ru',
  p_web_password                 => '643EAC40711A9034DFCBE9DE5DC0EADF5FFFF320',
  p_web_password_format          => '5;2;10000',
  p_group_ids                    => '5740767839632071:',
  p_developer_privs              => '',
  p_default_schema               => 'REST',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201709280000','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'N',
  p_allow_sql_workshop_yn        => 'N',
  p_allow_websheet_dev_yn        => 'N',
  p_allow_team_development_yn    => 'N',
  p_attribute_01                 => '17318',
  p_attribute_02                 => '222-22-22',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '2522911350207983',
  p_user_name                    => 'REST1',
  p_first_name                   => 'Алексей',
  p_last_name                    => 'Руснак',
  p_description                  => '',
  p_email_address                => 'REST1@REST1.ru',
  p_web_password                 => 'EC13AB233622A738B8A0667FBC62DBEB2BFB8030',
  p_web_password_format          => '5;2;10000',
  p_group_ids                    => '5740894262635768:',
  p_developer_privs              => '',
  p_default_schema               => 'REST',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201804030000','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 3,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'N',
  p_allow_sql_workshop_yn        => 'N',
  p_allow_websheet_dev_yn        => 'N',
  p_allow_team_development_yn    => 'N',
  p_attribute_01                 => '10050',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '1861989050996139',
  p_user_name                    => 'SBC',
  p_first_name                   => '',
  p_last_name                    => '',
  p_description                  => '',
  p_email_address                => 'servicedesk@mobilesol.ru',
  p_web_password                 => 'BE76C8D138B543296B4BD5EF1601A1032A0AA585',
  p_web_password_format          => '5;2;10000',
  p_group_ids                    => '1653425778130823:1653552153130823:1653604754130823:5740767839632071:5740894262635768:5741938931691589:',
  p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
  p_default_schema               => 'REST',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201709280000','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'Y',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '5829122535022020',
  p_user_name                    => 'TEST',
  p_first_name                   => 'Иван',
  p_last_name                    => 'Иванов',
  p_description                  => 'Администратор',
  p_email_address                => 'x@x.ru',
  p_web_password                 => '28B018E938F4005E29100D92E38DB86488AD183A',
  p_web_password_format          => '5;2;10000',
  p_group_ids                    => '5740894262635768:',
  p_developer_privs              => '',
  p_default_schema               => 'REST',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201709291754','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 1,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'Y',
  p_allow_sql_workshop_yn        => 'Y',
  p_allow_websheet_dev_yn        => 'Y',
  p_allow_team_development_yn    => 'N',
  p_attribute_01                 => '10036',
  p_allow_access_to_schemas      => '');
end;
/
begin
wwv_flow_fnd_user_api.create_fnd_user (
  p_user_id                      => '5852121720416839',
  p_user_name                    => 'TEST3',
  p_first_name                   => 'Петр',
  p_last_name                    => 'Петров',
  p_description                  => 'Обычный пользователь',
  p_email_address                => 'x@x.ru',
  p_web_password                 => 'E6F90DB2D50C67C38371FBE77913C0D8CE302BDD',
  p_web_password_format          => '5;2;10000',
  p_group_ids                    => '5740894262635768:',
  p_developer_privs              => '',
  p_default_schema               => 'REST',
  p_account_locked               => 'N',
  p_account_expiry               => to_date('201702171733','YYYYMMDDHH24MI'),
  p_failed_access_attempts       => 0,
  p_change_password_on_first_use => 'Y',
  p_first_password_use_occurred  => 'N',
  p_allow_app_building_yn        => 'N',
  p_allow_sql_workshop_yn        => 'N',
  p_allow_websheet_dev_yn        => 'N',
  p_allow_team_development_yn    => 'N',
  p_attribute_01                 => '16503',
  p_allow_access_to_schemas      => '');
end;
/
prompt Check Compatibility...
begin
-- This date identifies the minimum version required to import this file.
wwv_flow_team_api.check_version(p_version_yyyy_mm_dd=>'2010.05.13');
end;
/
 
begin wwv_flow.g_import_in_progress := true; wwv_flow.g_user := USER; end; 
/
 
--
prompt ...news
--
begin
null;
end;
/
--
prompt ...links
--
begin
null;
end;
/
--
prompt ...bugs
--
begin
null;
end;
/
--
prompt ...events
--
begin
null;
end;
/
--
prompt ...features
--
begin
null;
end;
/
--
prompt ...tasks
--
begin
null;
end;
/
--
prompt ...feedback
--
begin
null;
end;
/
--
prompt ...task defaults
--
begin
null;
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
