CREATE OR REPLACE PACKAGE REST_API AS

  PkgVersion    varchar2(10) := 'v.1.0.0'; -- Версия пакета
  ApexAppId     number := 100; -- ИД Апекс-приложения
  ApexAppPageId number := 1; -- ИД страницы Апекс-приложения
  WorkspaceName varchar2(255) := 'REST'; -- Воркспейс

  type ErrorsArrType is varray(10) of rest_api_err;

  Errors ErrorsArrType;

  /*
  Выводит ошикку
  */
  procedure PrintErrorJson(pErrNum in number);

  /*
  Выводит ошибку
  */
  procedure PrintErrorJson(pErrNum in rest_api_err);

  /*
  Главная процедура, точка входа
  */
  procedure Api(pBody in clob);

  /*
  Логин
  */
  function Login return rest_api_err;

  /*
  Логаут
  */
  function Logout return rest_api_err;

  /*
  Проверка годности сессии
  */
  function IsSessionValid return boolean;

  /*
  Вывод данных пользователя
  */
  procedure PrintEcho;

  /*
  Сотрудники - пока просто пример
  */
  procedure Employees(pStatus out number);

  /*
  Вывод списка заказов
  */

  type t_Order is record(
    empno emp.empno%type,
    ename emp.ename%type,
    job   emp.job%type,
    rn    number);

  type tbl_Orders is table of t_Order;

  function getOrders return tbl_Orders
    pipelined
    parallel_enable;

  procedure PrintOrders;

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
    lWorkspaceId number;
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOperation varchar2(255) := '';
  
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
        
        WHEN 'logout' THEN
          if IsSessionValid() then
            lError := Logout();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'echo' THEN
          if IsSessionValid() then
            apex_json.open_object('data');
            PrintEcho();
            apex_json.close_object;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'orders' THEN
          if IsSessionValid() then
            PrintOrders();
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
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
  
    lSession         varchar2(40);
    lToken           varchar2(40);
    lSessionLifeTime date;
  
    lIsSessionValid  boolean;
    lIsAuthenticated boolean;
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
  begin
  
    begin
      lUsername := apex_json.get_varchar2('data.username');
      lPassword := apex_json.get_varchar2('data.password');
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
          lIsSuccess     := false;
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
        APEX_UTIL.set_preference('TOKEN',
                                 lToken,
                                 APEX_CUSTOM_AUTH.GET_USERNAME);
      
        select t.session_idle_timeout_on
          into lSessionLifeTime
          from APEX_WORKSPACE_SESSIONS t
         where t.apex_session_id = lSession
           and t.workspace_name = WorkspaceName;
      
        apex_json.write('session_lifetime', lSessionLifeTime);
      
        PrintEcho();
      
      else
        lError := Errors(2);
      end if;
    
      apex_json.close_object;
    end if;
  
    return lError;
  end;

  function Logout return rest_api_err is
  
    lError rest_api_err := Errors(1);
  
  begin
  
    begin
    
      APEX_UTIL.set_preference('TOKEN',
                               dbms_random.string('A', 40),
                               APEX_CUSTOM_AUTH.GET_USERNAME);
    
    exception
      when others then
        lError         := Errors(2);
        lError.message := sqlerrm;
    end;
  
    return lError;
  
  end;

  function IsSessionValid return boolean is
  
    lIsAuthenticated boolean;
  
    lIsSuccess boolean := true;
  
    lSession varchar2(255);
  
    lToken varchar2(255);
  
  begin
  
    begin
      lSession := apex_json.get_varchar2('session');
      lToken   := apex_json.get_varchar2('token');
    exception
      when others then
        lIsSuccess := false;
    end;
  
    apex_application.g_instance     := lSession;
    apex_application.g_flow_id      := ApexAppId;
    apex_application.g_flow_step_id := ApexAppPageId;
  
    lIsAuthenticated := APEX_AUTHENTICATION.IS_AUTHENTICATED;
  
    if lIsAuthenticated then
      if APEX_UTIL.get_preference('TOKEN', APEX_CUSTOM_AUTH.GET_USERNAME) =
         lToken then
        lIsSuccess := true;
        APEX_CUSTOM_AUTH.SET_SESSION_ID(lSession);
        APEX_CUSTOM_AUTH.SET_USER(APEX_CUSTOM_AUTH.GET_USERNAME);
      else
        lIsSuccess := false;
      end if;
    else
      lIsSuccess := false;
    end if;
  
    return lIsSuccess;
  end;

  procedure PrintEcho is
    lCurrentUserId   number;
    lCurrentUserName varchar2(255);
  begin
    apex_json.open_object('user');
  
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCurrentUserId   := APEX_UTIL.GET_USER_ID(lCurrentUserName);
  
    apex_json.write('id', lCurrentUserId);
    apex_json.write('login', lCurrentUserName);
    apex_json.write('email', APEX_UTIL.GET_EMAIL(lCurrentUserName));
    apex_json.write('phone', APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 2));
    apex_json.write('first_name',
                    APEX_UTIL.GET_FIRST_NAME(lCurrentUserName));
    apex_json.write('last_name', APEX_UTIL.GET_LAST_NAME(lCurrentUserName));
  
    apex_json.write('company',
                    APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1));
  
    apex_json.close_object;
  end;

  procedure Employees(pStatus out number) is
  
    lIsSuccess boolean;
  
    lError rest_api_err := Errors(3);
  
    lRc sys_refcursor;
  begin
  
    --lIsSuccess := IsSessionValid(pSession, pToken);
  
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

  /*
  Вывод списка заказов
  */
  procedure PrintOrders is
    lCurrentUserId   number;
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lCollectionName   varchar2(255) := 'ORDERS';
    lCollectionExists boolean;
  
    lRc sys_refcursor;
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCurrentUserId   := APEX_UTIL.GET_USER_ID(lCurrentUserName);
    lCompanyId       := APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1);
  
    -- Формирование коллекции
    lCollectionExists := APEX_COLLECTION.COLLECTION_EXISTS(lCollectionName);
  
    if lCollectionExists then
      APEX_COLLECTION.DELETE_COLLECTION(lCollectionName);
    end if;
  
    APEX_COLLECTION.CREATE_COLLECTION(lCollectionName);
  
    for l_c in (select * from TABLE(getOrders())) loop
      APEX_COLLECTION.ADD_MEMBER(p_collection_name => lCollectionName,
                                 p_c001            => l_c.rn,
                                 p_c002            => l_c.empno,
                                 p_c003            => l_c.ename,
                                 p_c004            => l_c.job);
    end loop;
  
    open lRc for
      select c.c001 "rn", c.c002 "empno", c.c003 "ename", c.c004 "job"
        from apex_collections c
       where c.collection_name = lCollectionName;
    apex_json.write('data', lRc);
  
  end;

  function getOrders return tbl_Orders
    pipelined
    parallel_enable is
  begin
    for cur in (select emp.empno,
                       emp.ename,
                       emp.job,
                       row_number() over(order by empno) rn
                  from emp) loop
    
      pipe row(cur);
    
    end loop;
  
    return;
  
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
