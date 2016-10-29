set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_default_workspace_id=>1804345722063826
);
end;
/
prompt  Set Application Offset...
begin
   -- SET APPLICATION OFFSET
   wwv_flow_api.g_id_offset := nvl(wwv_flow_application_install.get_offset,0);
null;
end;
/
begin
wwv_flow_api.remove_restful_service(
 p_id=>wwv_flow_api.id(5439605281075860)
,p_name=>'REST_API'
);
 
end;
/
prompt --application/restful_services/rest_api
begin
wwv_flow_api.create_restful_module(
 p_id=>wwv_flow_api.id(5439605281075860)
,p_name=>'REST_API'
,p_parsing_schema=>'REST'
,p_items_per_page=>25
,p_status=>'PUBLISHED'
,p_row_version_number=>14
);
wwv_flow_api.create_restful_template(
 p_id=>wwv_flow_api.id(5439749106288000)
,p_module_id=>wwv_flow_api.id(5439605281075860)
,p_uri_template=>'api/'
,p_priority=>0
,p_etag_type=>'HASH'
);
wwv_flow_api.create_restful_handler(
 p_id=>wwv_flow_api.id(5439864746303521)
,p_template_id=>wwv_flow_api.id(5439749106288000)
,p_source_type=>'PLSQL'
,p_format=>'DEFAULT'
,p_method=>'POST'
,p_require_https=>'YES'
,p_source=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'begin',
'  ',
'  rest_api.api(pbody => wwv_flow_utilities.blob_to_clob(:body));',
'  ',
'end;'))
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
