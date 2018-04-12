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
,p_row_version_number=>48
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
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  ',
'  rest_api.api(pbody => wwv_flow_utilities.blob_to_clob(:body));',
'  ',
'end;'))
);
wwv_flow_api.create_restful_template(
 p_id=>wwv_flow_api.id(2631913528032272)
,p_module_id=>wwv_flow_api.id(5439605281075860)
,p_uri_template=>'api/download/{token}'
,p_priority=>0
,p_etag_type=>'HASH'
);
wwv_flow_api.create_restful_handler(
 p_id=>wwv_flow_api.id(2632065715038881)
,p_template_id=>wwv_flow_api.id(2631913528032272)
,p_source_type=>'PLSQL'
,p_format=>'DEFAULT'
,p_method=>'GET'
,p_require_https=>'YES'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  ',
'  rest_api.api(pbody => ''{"operation":"files_archive_download", "filter":{"link_token":"''||:token||''"}}'');',
'  ',
'end;'))
);
wwv_flow_api.create_restful_template(
 p_id=>wwv_flow_api.id(5574424731321327)
,p_module_id=>wwv_flow_api.id(5439605281075860)
,p_uri_template=>'api/file/'
,p_priority=>0
,p_etag_type=>'HASH'
);
wwv_flow_api.create_restful_handler(
 p_id=>wwv_flow_api.id(5574673973342388)
,p_template_id=>wwv_flow_api.id(5574424731321327)
,p_source_type=>'PLSQL'
,p_format=>'DEFAULT'
,p_method=>'POST'
,p_require_https=>'YES'
,p_source=>wwv_flow_string.join(wwv_flow_t_varchar2(
'begin',
'  ',
'  rest_api.ApiFile(pSession => :XSession, pToken => :XToken, pDocId   => :XDocId, pFileId   => :XFileId, pFileBody => :body, pMime => :XFile);',
'  --htp.print(wwv_flow_utilities.blob_to_clob(:body));',
'  ',
'end;'))
);
wwv_flow_api.create_restful_param(
 p_id=>wwv_flow_api.id(5874443033054861)
,p_handler_id=>wwv_flow_api.id(5574673973342388)
,p_name=>'X-DocId'
,p_bind_variable_name=>'XDocId'
,p_source_type=>'HEADER'
,p_access_method=>'IN'
,p_param_type=>'STRING'
);
wwv_flow_api.create_restful_param(
 p_id=>wwv_flow_api.id(5594205755693345)
,p_handler_id=>wwv_flow_api.id(5574673973342388)
,p_name=>'X-File'
,p_bind_variable_name=>'XFile'
,p_source_type=>'HEADER'
,p_access_method=>'IN'
,p_param_type=>'STRING'
);
wwv_flow_api.create_restful_param(
 p_id=>wwv_flow_api.id(5594966745918676)
,p_handler_id=>wwv_flow_api.id(5574673973342388)
,p_name=>'X-FileId'
,p_bind_variable_name=>'XFileId'
,p_source_type=>'HEADER'
,p_access_method=>'IN'
,p_param_type=>'STRING'
);
wwv_flow_api.create_restful_param(
 p_id=>wwv_flow_api.id(5594059449384817)
,p_handler_id=>wwv_flow_api.id(5574673973342388)
,p_name=>'X-Session'
,p_bind_variable_name=>'XSession'
,p_source_type=>'HEADER'
,p_access_method=>'IN'
,p_param_type=>'STRING'
);
wwv_flow_api.create_restful_param(
 p_id=>wwv_flow_api.id(5594121616386287)
,p_handler_id=>wwv_flow_api.id(5574673973342388)
,p_name=>'X-Token'
,p_bind_variable_name=>'XToken'
,p_source_type=>'HEADER'
,p_access_method=>'IN'
,p_param_type=>'STRING'
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
