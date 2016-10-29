CREATE OR REPLACE PACKAGE REST_API AS

  PkgVersion    varchar2(10) := 'v.1.0.0'; -- Версия пакета
  ApexAppId     number := 100; -- ИД Апекс-приложения
  ApexAppPageId number := 1; -- ИД страницы Апекс-приложения
  WorkspaceName varchar2(255) := 'REST'; -- Воркспейс

  type ErrorsArrType is varray(10) of rest_api_err;

  Errors ErrorsArrType;

  procedure PrintErrorJson(pErrNum in number);

  procedure PrintErrorJson(pErrNum in rest_api_err);

  procedure Api(pBody in clob);

  function Login return rest_api_err;

  procedure CheckSession(pSession in varchar2,
                         pToken   in varchar2,
                         pStatus  out number);

  function IsSessionValid(pSession in varchar2, pToken in varchar2)
    return boolean;

  procedure Employees(pSession in varchar2,
                      pToken   in varchar2,
                      pStatus  out number);

END REST_API;
/
CREATE OR REPLACE PACKAGE BODY REST_API AS

  procedure PrintErrorJson(pErrNum in number) is
  begin
  
    PrintErrorJson(Errors(pErrNum));
  
  end;

  procedure PrintErrorJson(pErrNum in rest_api_err) is
  begin
  
    apex_json.open_object('error');
  
    apex_json.write('code', pErrNum.code);
  
    apex_json.write('message', pErrNum.message);
  
    apex_json.close_object;
  
  end;

  procedure Api(pBody in clob) is
  
    lSession     varchar2(40);
    lToken       varchar2(40);
    lWorkspaceId number;
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOperation varchar2(255) := '';
  
    lOutput clob := '';
  
  begin
  
    apex_json.initialize_clob_output;
  
    apex_json.open_object;
  
    begin
      lWorkspaceId := apex_util.find_security_group_id(p_workspace => WorkspaceName);
      apex_util.set_security_group_id(p_security_group_id => lWorkspaceId);
    exception
      when others then
        lIsSuccess     := false;
        lError         := Errors(3);
        lError.message := sqlerrm;
    end;
  
    if lIsSuccess then
      begin
        apex_json.parse(pBody);
      exception
        when others then
          lIsSuccess     := false;
          lError         := Errors(3);
          lError.message := sqlerrm;
      end;
    end if;
  
    if lIsSuccess then
      begin
        lOperation := apex_json.get_varchar2('operation');
      exception
        when others then
          lIsSuccess := false;
          lError     := Errors(4);
      end;
    end if;
  
    if lIsSuccess then
      CASE lOperation
        WHEN 'login' THEN
          lError := Login();
          if lError.success != 1 then
            lIsSuccess := false;
          end if;
        
        WHEN 'echo' THEN
          apex_json.write('data', 'echo');
        ELSE
          lIsSuccess := false;
          lError     := Errors(4);
      END CASE;
    end if;
  
    apex_json.write('success', lIsSuccess);
  
    if lIsSuccess != true then
      PrintErrorJson(lError);
    end if;
  
    apex_json.close_object;
  
    htp.p(APEX_JSON.get_clob_output);
  
    apex_json.free_output;
  
  end;

  function Login return rest_api_err is
  
    lUsername varchar2(255);
    lPassword varchar2(255);
  
    lSession varchar2(40);
    lToken   varchar2(40);
  
    lIsSessionValid  boolean;
    lIsAuthenticated boolean;
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lCurrentUserId   number;
    lCurrentUserName varchar2(255);
  
  begin
  
    begin
      lUsername := apex_json.get_varchar2('username');
      lPassword := apex_json.get_varchar2('password');
    exception
      when others then
        lIsSuccess     := false;
        lError         := Errors(3);
        lError.message := sqlerrm;
    end;
  
    if lIsSuccess then
      begin
      
        apex_custom_auth.login(p_uname      => lUsername,
                               p_password   => lPassword,
                               p_session_id => apex_custom_auth.get_next_session_id,
                               p_app_page   => ApexAppId || ':' ||
                                               ApexAppPageId);
      
      exception
        when others then
          lError         := Errors(2);
          lError.message := sqlerrm;
      end;
    end if;
  
    if lIsSuccess then
      lIsSessionValid  := APEX_CUSTOM_AUTH.IS_SESSION_VALID;
      lIsAuthenticated := APEX_AUTHENTICATION.IS_AUTHENTICATED;
    
      if lIsSessionValid and lIsAuthenticated then
        lIsSuccess := true;
      else
        lIsSuccess := false;
      end if;
    
      apex_json.open_object('data');
    
      if lIsSuccess then
        lSession := apex_application.g_instance;
        lToken   := dbms_random.string('A', 40);
        apex_json.write('session', lSession);
        apex_json.write('token', lToken);
        APEX_UTIL.SET_SESSION_STATE('TOKEN', lToken);
      
        apex_json.open_object('user');
      
        lCurrentUserId   := APEX_UTIL.GET_CURRENT_USER_ID;
        lCurrentUserName := upper(APEX_UTIL.GET_USERNAME(lCurrentUserId));
      
        apex_json.write('id', lCurrentUserId);
        apex_json.write('login', lCurrentUserName);
        apex_json.write('email', APEX_UTIL.GET_EMAIL(lCurrentUserName));
        apex_json.write('first_name',
                        APEX_UTIL.GET_FIRST_NAME(lCurrentUserName));
        apex_json.write('last_name',
                        APEX_UTIL.GET_LAST_NAME(lCurrentUserName));
      
        apex_json.close_object;
      
      else
        lError := Errors(2);
      end if;
    
      apex_json.close_object;
    end if;
  
    return lError;
  end;

  procedure CheckSession(pSession in varchar2,
                         pToken   in varchar2,
                         pStatus  out number) is
    lIsSuccess boolean;
    lError     rest_api_err := Errors(1);
  begin
  
    lIsSuccess := IsSessionValid(pSession, pToken);
  
    apex_json.initialize_clob_output;
  
    apex_json.open_object;
  
    apex_json.write('success', lIsSuccess);
  
    if lIsSuccess then
      pStatus := 200;
    else
      PrintErrorJson(lError);
      pStatus := 401;
    end if;
  
    apex_json.close_object;
  
    htp.p(APEX_JSON.get_clob_output);
  
    apex_json.free_output;
  
  end;

  function IsSessionValid(pSession in varchar2, pToken in varchar2)
    return boolean is
  
    lWorkspaceId number;
  
    lIsAuthenticated boolean;
  
    lIsSuccess boolean;
  
  begin
  
    lWorkspaceId := apex_util.find_security_group_id(p_workspace => WorkspaceName);
    apex_util.set_security_group_id(p_security_group_id => lWorkspaceId);
  
    apex_application.g_instance     := pSession;
    apex_application.g_flow_id      := ApexAppId;
    apex_application.g_flow_step_id := ApexAppPageId;
  
    lIsAuthenticated := APEX_AUTHENTICATION.IS_AUTHENTICATED;
  
    if lIsAuthenticated then
      if APEX_UTIL.FETCH_APP_ITEM('TOKEN', ApexAppId) = pToken then
        lIsSuccess := true;
      else
        lIsSuccess := false;
      end if;
    else
      lIsSuccess := false;
    end if;
  
    return lIsSuccess;
  end;

  procedure Employees(pSession in varchar2,
                      pToken   in varchar2,
                      pStatus  out number) is
  
    lIsSuccess boolean;
  
    lError rest_api_err := Errors(3);
  
    lRc sys_refcursor;
  begin
  
    lIsSuccess := IsSessionValid(pSession, pToken);
  
    apex_json.initialize_clob_output;
  
    apex_json.open_object;
  
    apex_json.write('success', lIsSuccess);
  
    if not lIsSuccess then
      PrintErrorJson(lError);
      pStatus := 401;
    else
      pStatus := 200;
      open lRc for
        select emp.*, row_number() over(order by empno) rn from emp;
      apex_json.write('data', lRc);
    end if;
  
    apex_json.close_object;
  
    htp.p(APEX_JSON.get_clob_output);
  
    apex_json.free_output;
  
  end;

BEGIN

  Errors := ErrorsArrType();

  Errors.EXTEND(4);

  Errors(1) := rest_api_err('success', 'success', 1);

  Errors(2) := rest_api_err('unauthorized', 'Unauthorized', 0);

  Errors(3) := rest_api_err('service_internal_error',
                            'Service internal error',
                            0);

  Errors(4) := rest_api_err('bad_operation', 'Bad operation', 0);

END REST_API;
/
