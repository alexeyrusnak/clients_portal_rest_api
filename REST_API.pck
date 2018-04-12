CREATE OR REPLACE PACKAGE REST_API AS

  PkgVersion    varchar2(10) := 'v.1.0.0'; -- Версия пакета
  ApexAppId     number := 100; --100; -- ИД Апекс-приложения
  ApexAppPageId number := 1; -- ИД страницы Апекс-приложения
  WorkspaceName varchar2(255) := 'REST'; -- Воркспейс

  PkgDefaultDateFormat varchar2(255) := 'YYYY-MM-DD HH24:MI:SS'; -- Формат даты при конвертациях в строку и обратно
  PkgDefaultDateShortFormat varchar2(255) := 'YYYY-MM-DD'; -- Формат даты при конвертациях в строку и обратно
  PkgDefaultOffset     number := 0; -- Значение по умолчанию для переменной offset
  PkgDefaultLimit      number := 100; -- Значение по умолчанию для переменной limit

  PkgDefaultPeriodIndays number := 1450; -- Период по умолчанию для всех запросов в днях
  
  PkgClientIdAttributeNumber number := 1;

  type ErrorsArrType is varray(10) of rest_api_err;

  Errors ErrorsArrType;

  /*
  Выводит ошибку
  */
  procedure PrintErrorJson(pErrNum in number);

  /*
  Выводит ошибку
  */
  procedure PrintErrorJson(pErrNum in rest_api_err);

  /*
  Выводит clob в http
  */
  procedure HtpPrn(pclob in clob);

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
  function IsSessionValid(pSession in varchar2 default null,
                          pToken   in varchar2 default null) return boolean;

  /*
  Вывод данных пользователя
  */
  procedure PrintEcho;

  /*
  Сотрудники - пока просто пример
  */
  procedure Employees(pStatus out number);

  /*
  Вывод списка заказов - п.4.7.3 ТЗ на АПИ
  */
  function PrintOrders return rest_api_err;

  /*
  Вывод информации по конкретному заказу
  */
  function PrintOrder return rest_api_err;
  
  /*
  Вывод списка документов - п.4.8.5 ТЗ на АПИ
  */
  function PrintDocs return rest_api_err;
  
  /*
  Вывод информации по конкретному документу - п.4.8.2 ТЗ на АПИ
  */
  function PrintDoc return rest_api_err;
  
  /*
  Функция для обновления документов - п.4.8.1 ТЗ на АПИ
  */
  function CreateDoc return rest_api_err;
  
  /*
  Функция для обновления документов - п.4.8.2 ТЗ на АПИ
  */
  function UpdateDoc return rest_api_err;
  
  /*
  Функция удаления документов - п.4.8.4 ТЗ на АПИ
  */
  function RemoveDoc return rest_api_err;
  
  /*
  Функция для сохранения файлов - п.4.8.6 ТЗ на АПИ
  */
  function SaveFile(pDocId  in number,
                    pClntId in number,
                    pFile   in blob,
                    pMime   in varchar2,
                    pFileId out number) return rest_api_err;
                    
  /*
  Функция возвращает файл - п.4.8.7 ТЗ на АПИ
  */
  function DownloadFile(pClntId in number, pFileId in number)
    return rest_api_err;
    
  /*
  Функция удаления документов - п.4.8.6 ТЗ на АПИ
  */
  function AddFileToDoc return rest_api_err;
  
  /*
  Вывод списка файлов - п.4.8.7 ТЗ на АПИ
  */
  function PrintFiles return rest_api_err;
  
  /*
  Вывод ссылка на архив с документами - п.4.8.8 ТЗ на АПИ
  */
  function PrintFilesZipLink return rest_api_err;
  
  /*
  Функция возвращает zip файл - п.4.8.8 ТЗ на АПИ
  */
  function DownloadZipFile return rest_api_err;

  /*
  Файловый API
  */
  procedure ApiFile(pSession  in varchar2,
                    pToken    in varchar2,
                    pDocId    in number default null,
                    pFileId   in number default null,
                    pFileBody in blob default null,
                    pMime     in varchar2 default null);
  
  /*
  Вывод списка стран
  */
  function PrintCountryList return rest_api_err;

  /*
  Вывод списка регионов
  */
  function PrintRegionList return rest_api_err;

  /*
  Вывод списка городов
  */
  function PrintCityList return rest_api_err;

  /*
  Вывод списка типов документов
  */
  function PrintDocTypList return rest_api_err;
  
    /*
  Вывод справочника статусов
  */
  function PrintStatusesDic return rest_api_err;

  /*
  Вывод коллекции документов Ю.К. 26.06.2017
  */
  function PrintDocs_depricated return rest_api_err;
  
  /*
   Вывод информации по компании
  */
  function Companies return rest_api_err;

  -- Отчет о грузах п.4.14.2 в ТЗ на разработку АПИ (операция report_order)
  -- Ю.К. 23.03.2017
  function report_order return rest_api_err;

  -- Данные о контрагенте п.4.3.1 в ТЗ на разработку АПИ (операция contractors_get)
  -- Ю.К. 14.04.2017
  function contractors_get return rest_api_err;

  -- Коллекции контрагентов п.4.3.2 в ТЗ на разработку АПИ (операция contractors)
  -- Ю.К. 17.04.2017
  function contractors return rest_api_err;

  -- Адрес доставки. Просмотр п.4.4.2 в ТЗ на разработку АПИ (операция delivery_points_get)
  -- Ю.К. 18.04.2017
  function delivery_points_get return rest_api_err;

  -- Адрес доставки. Получение коллекции п.4.4.5 в ТЗ на разработку АПИ (операция delivery_points)
  -- Ю.К. 20.04.2017
  function delivery_points return rest_api_err;

  -- Задолженность. Получение коллекции. п. 4.10.1 в ТЗ на разработку АПИ (операция debts)
  -- Ю.К. 24.04.2017
  function debts return rest_api_err;

  -- Коллекции контрагентов. Получение коллекции. п. 4.3.1.1 в ТЗ на разработку АПИ (операция shippers)
  --
  function shippers return rest_api_err;

  -- Коллекции контрагентов. Получение коллекции. п. 4.3.1.1 в ТЗ на разработку АПИ (операция consignees)
  -- 
  function consignees return rest_api_err;
  
  function Test return rest_api_err;

  /*
   Журнал протоколирования ошибок и тестирования
  */
  procedure ins_syslog(mess in varchar2, logdate in date);
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

  procedure HtpPrn(pclob in clob) is
    v_excel varchar2(32000);
    v_clob  clob := pclob;
  begin
    while length(v_clob) > 0 loop
      begin
        if length(v_clob) > 16000 then
          v_excel := substr(v_clob, 1, 16000);
          htp.prn(v_excel);
          v_clob := substr(v_clob, length(v_excel) + 1);
        else
          v_excel := v_clob;
          htp.prn(v_excel);
          v_clob  := '';
          v_excel := '';
        end if;
      end;
    end loop;
  end;

  procedure Api(pBody in clob) is
    lWorkspaceId number;
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOperation varchar2(255) := '';
  
  begin
    
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
    
    apex_json.initialize_clob_output;
    apex_json.open_object;
  
    if lIsSuccess then
      CASE lOperation
        WHEN 'TEST' THEN
          lError.message := 'qwerty';
        
        -- Авторизация пользователя портала
        WHEN 'login' THEN
          lError := Login();
          if lError.success != 1 then
            lIsSuccess := false;
          end if;
        -- выход из портала
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
        WHEN 'test' THEN
          if IsSessionValid() then
            lError := Test();           
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        -- П.4.7.3 ТЗ на АПИ - получение списка заказов
        WHEN 'orders' THEN
          if IsSessionValid() then
            lError := PrintOrders();           
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        -- Пункт 4.7.2 ТЗ на АПИ - получение информации по заказу
        WHEN 'orders_get' THEN
          if IsSessionValid() then
            lError := PrintOrder();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'country_list' THEN
          if IsSessionValid() then
            lError := PrintCountryList();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'region_list' THEN
          if IsSessionValid() then
            lError := PrintRegionList();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'city_list' THEN
          if IsSessionValid() then
            lError := PrintCityList();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'doctype_list' THEN
          if IsSessionValid() then
            lError := PrintDocTypList();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          
        WHEN 'statuses' THEN
          if IsSessionValid() then
            lError := PrintStatusesDic();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          
        WHEN 'orders_doc' THEN
          if IsSessionValid() then
            lError := PrintDoc();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'orders_docs' THEN
          if IsSessionValid() then
            lError := PrintDocs();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'orders_doc_create' THEN
          if IsSessionValid() then
            lError := CreateDoc();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'orders_doc_update' THEN
          if IsSessionValid() then
            lError := UpdateDoc();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
        
        WHEN 'orders_doc_delete' THEN
          if IsSessionValid() then
            lError := RemoveDoc();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          
        WHEN 'create_file' THEN
          if IsSessionValid() then
            lError := AddFileToDoc();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          
        WHEN 'files' THEN
          if IsSessionValid() then
            lError := PrintFiles();           
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          
        WHEN 'files_archive' THEN
          if IsSessionValid() then
            lError := PrintFilesZipLink();           
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          
        WHEN 'files_archive_download' THEN
          lError := DownloadZipFile();           
          if lError.success != 1 then
            lIsSuccess := false;
          else
            apex_json.close_object;
            apex_json.free_output;
            return;
          end if;   
          
          -- Вывод информации по компании       
        WHEN 'companies' THEN
          if IsSessionValid() then
            lError := Companies();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          -- Отчет "Заказы" (report_order). Ю.К. 23.03.2017:
        when 'report_order' then
          if IsSessionValid() then
            lError := report_order();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          -- Данные о контрагенте (contractors_get). Ю.К. 14.04.2017:
        when 'contractors_get' then
          if IsSessionValid() then
            lError := contractors_get();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          -- Коллекция контрагентов (contractors). Ю.К. 17.04.2017:
        when 'contractors' then
          if IsSessionValid() then
            lError := contractors();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          -- Адрес доставки. Просмотр (delivery_points_get). Ю.К. 18.04.2017:
        when 'delivery_points_get' then
          if IsSessionValid() then
            lError := delivery_points_get();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          -- Адрес доставки. Коллекция (delivery_points). Ю.К. 20.04.2017:
        when 'delivery_points' then
          if IsSessionValid() then
            lError := delivery_points();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          -- Задолженность. Получение коллекции (debts). Ю.К. 24.04.2017:
        when 'debts' then
          if IsSessionValid() then
            lError := debts();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          -- Коллекция грузоотправителей клиента
        when 'shippers' then
          if IsSessionValid() then
            lError := shippers();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
          else
            lIsSuccess := false;
            lError     := Errors(2);
          end if;
          -- Коллекция грузополучателей клиента
        when 'consignees' then
          if IsSessionValid() then
            lError := consignees();
            if lError.success != 1 then
              lIsSuccess := false;
            end if;
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
    
    sys.htp.init;
    sys.owa_util.mime_header('application/json', false, 'UTF-8');
    sys.owa_util.http_header_close;
  
    HtpPrn(APEX_JSON.get_clob_output);
  
    apex_json.free_output;
  
  end;
  -- авторизация пользователя портала
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
      -- Получаем логин и пароль из запроса в формате JSON
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
        -- 29.09.2017 This procedure generates a newline character to close the HTTP header.
        -- The HTTP header must be closed before any htp.print or htp.prn calls.
        owa_util.http_header_close;
        /*
        sbc.ins_sys_logs(ApplId   => 2,
                         Message  => 'Login Ok',
                         IsCommit => true); */
      exception
        when others then
          sbc.ins_sys_logs(ApplId   => 2,
                           Message  => SQLERRM,
                           IsCommit => true);
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

  -- выход из портала (деавторизация)
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

  function IsSessionValid(pSession in varchar2 default null,
                          pToken   in varchar2 default null) return boolean is
  
    lIsAuthenticated boolean;
  
    lIsSuccess boolean := true;
  
    lSession varchar2(255);
  
    lToken varchar2(255);
  
  begin
  
    begin
      if pSession is not null then
        lSession := pSession;
      else
        lSession := apex_json.get_varchar2('session');
      end if;
    
      if pToken is not null then
        lToken := pToken;
      else
        lToken := apex_json.get_varchar2('token');
      end if;
    
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
    apex_json.write('name', APEX_UTIL.GET_FIRST_NAME(lCurrentUserName));                
    apex_json.write('last_name', APEX_UTIL.GET_LAST_NAME(lCurrentUserName));
    apex_json.write('company', APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1));
  
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
  Вывод списка заказов - п.4.7.3 ТЗ на АПИ
  */
  function PrintOrders return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lCollectionName   varchar2(255) := 'ORDERS';
    lCollectionExists boolean;
  
    lOffset number;
    lLimit  number;
    
    lFiltersState    varchar2(4000) := null;
    lFiltersPrevious varchar2(4000) := null;
  
    lShouldResetCollection boolean := true;
    lColectionCount        number := 0;
    
    -- Filters
    lFilter varchar2(4000);
    lQueryFilter varchar2(200);
    
    -- Sort
    lSorts varchar2(200);
    
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1));
    
    -- Filters
    begin
      lOffset := apex_json.get_number(p_path    => 'offset',
                                      p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit',
                                      p_default => PkgDefaultLimit);
      
      --if lOffset is null then lOffset := 0; end if;
      --if lLimit is null then lLimit := 1000; end if;
                                      
      rest_api_helper.AddFilter('id', null, lFilter); -- Идентификатор заказа
      
      rest_api_helper.AddFilter('created_at', null, lFilter); -- Дата создания заказа
      
      rest_api_helper.AddFilter('date_from', null, lFilter); -- Дата отправки заказа
      
      rest_api_helper.AddFilter('date_to', null, lFilter); -- Дата прибытия заказа
      
      rest_api_helper.AddFilter('status', null, lFilter); -- Cтатус
      
      rest_api_helper.AddFilter('status_id', null, lFilter); -- Идентификатор статуса
      
      rest_api_helper.AddFilter('date_closed', null, lFilter); -- Дата закрытия заказа
      
      rest_api_helper.AddFilter('shipment_date', null, lFilter); -- Дата погрузки
      
      rest_api_helper.AddFilter('te_number', null, lFilter); -- Номер ТЕ (с индексом)
      
      rest_api_helper.AddFilter('te_type', null, lFilter); -- Номер ТЕ (с индексом)
      
      rest_api_helper.AddFilter('unload_transhipment_plan_date', null, lFilter); -- Дата подхода в порт перевалки
      
      rest_api_helper.AddFilter('unload_destination_plan_date', 'unload_destination_plan_date', lFilter); -- Дата подхода в порт/СВХ назначения
      
      rest_api_helper.AddFilter('unload_destination_fact_date', 'unload_destination_fact_date', lFilter); -- Дата выгрузки в порту/СВХ назначения (факт)
      
      rest_api_helper.AddFilter('date_dt', 'date_dt', lFilter); -- Дата подачи ДТ
      
      rest_api_helper.AddFilter('date_release_dt', 'date_release_dt', lFilter); -- Дата выпуска ДТ
      
      rest_api_helper.AddFilter('date_export_port', 'date_export_port', lFilter); -- Дата вывоза из порта
      
      rest_api_helper.AddFilter('date_return_empty', 'date_return_empty', lFilter); -- Дата возврата порожнего
      
      rest_api_helper.AddFilter('customer_delivery_date', 'customer_delivery_date', lFilter); -- Дата выгрузки на склад
      
      rest_api_helper.AddFilter('dt_number', 'dt_number', lFilter); -- Номер ДТ
      
      rest_api_helper.AddFilter('am_number', 'am_number', lFilter); -- Номер АМ ?
      
      rest_api_helper.AddFilter('fio_driver', null, lFilter); -- ФИО водителя ?
      
      rest_api_helper.AddFilter('cargo_name', null, lFilter); -- Наименование груза
      
      rest_api_helper.AddFilter('departure_country', null, lFilter); -- Страна отправления груза
      
      rest_api_helper.AddFilter('port_svh', null, lFilter); -- Порт/СВХ
      
      rest_api_helper.AddFilter('place_from', null, lFilter); -- Адрес отправки 
      
      rest_api_helper.AddFilter('place_to', null, lFilter); -- Адрес назначения
      
      rest_api_helper.AddFilter('consignor.id', '"consignor.id"', lFilter);
      
      rest_api_helper.AddFilter('consignor.name', '"consignor.name"', lFilter); -- Грузоотправитель (Контрагент)
      
      rest_api_helper.AddFilter('consignee.id', '"consignee.id"', lFilter); 
      
      rest_api_helper.AddFilter('consignee.name', '"consignee.name"', lFilter); -- Грузополучатель (Контрагент)       
      
      lQueryFilter := replace(apex_json.get_varchar2('data.query', null), '''', '"');
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
    
    -- Order by
    begin
      
      rest_api_helper.AddSortFilter('id', null, lSorts);
      
      rest_api_helper.AddSortFilter('created_at', null, lSorts);
      
      rest_api_helper.AddSortFilter('date_from', null, lSorts);
      
      rest_api_helper.AddSortFilter('date_to', null, lSorts);
      
      rest_api_helper.AddSortFilter('receivables', null, lSorts);
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(6);
    end;
  
    -- Проверяем, изменились ли фильтры
    lFiltersPrevious := apex_util.get_preference(lCollectionName || apex_application.g_instance, lCurrentUserName);
                                                 
    lFiltersState := 'PrintOrdersFiltersState' || lFilter || lQueryFilter ||  lSorts;
                     
    if lFiltersPrevious = lFiltersState then
      lShouldResetCollection := false;
    end if;
  
    apex_util.set_preference(lCollectionName || apex_application.g_instance, lFiltersState, lCurrentUserName);
  
    if lIsSuccess then
       -- Формирование коллекции
       if lShouldResetCollection then
          lCollectionExists := APEX_COLLECTION.COLLECTION_EXISTS(lCollectionName);
      
       if lCollectionExists then
          APEX_COLLECTION.DELETE_COLLECTION(lCollectionName);
       end if;
       APEX_COLLECTION.CREATE_COLLECTION(lCollectionName);
        for lRc in (select *
                      from TABLE(mcsf_api.GetOrders(pClntId => lCompanyId,
                                                     pFilter => lFilter,
                                                     pQueryFilter => lQueryFilter,
                                                     pSortFilter => lSorts
                                                     ))) loop
          APEX_COLLECTION.ADD_MEMBER(p_collection_name => lCollectionName,
                                     p_c001            => lRc.id,
                                     p_c002            => lRc.place_from,
                                     p_c003            => lRc.place_to,
                                     p_c004            => lRc.status,
                                     p_c005            => lRc.status_id,
                                     p_c006            => lRc.receivables,
                                     p_c007            => lRc.amount,
                                     p_c008            => lRc.notification_count,
                                     p_c009            => lRc.cargo_name,
                                     p_c010            => to_char(lRc.created_at,PkgDefaultDateFormat),
                                     p_c011            => to_char(lRc.date_from,PkgDefaultDateFormat),
                                     p_c012            => to_char(lRc.date_to,PkgDefaultDateFormat),
                                     p_c013            => lRc.te_type,
                                     p_c014            => lRc.port_svh,
                                     p_c015            => lRc.departure_country,
                                     p_c016            => to_char(lRc.date_closed,PkgDefaultDateFormat),
                                     p_c017            => to_char(lRc.shipment_date,PkgDefaultDateFormat),
                                     p_c018            => to_char(lRc.unload_transhipment_plan_date,PkgDefaultDateFormat),
                                     p_c019            => to_char(lRc.unload_destination_plan_date,PkgDefaultDateFormat),
                                     p_c020            => to_char(lRc.unload_destination_fact_date,PkgDefaultDateFormat),
                                     p_c021            => to_char(lRc.date_dt,PkgDefaultDateFormat),
                                     p_c022            => to_char(lRc.date_release_dt,PkgDefaultDateFormat),
                                     p_c023            => lRc.dt_number,
                                     p_c024            => to_char(lRc.date_export_port,PkgDefaultDateFormat),
                                     p_c025            => to_char(lRc.date_return_empty,PkgDefaultDateFormat),
                                     p_c026            => to_char(lRc.customer_delivery_date,PkgDefaultDateFormat),
                                     p_c027            => lRc.am_number,
                                     p_c028            => lRc.fio_driver,
                                     p_c029            => lRc."consignor.id",
                                     p_c030            => lRc."consignor.name",
                                     p_c031            => lRc."consignee.id",
                                     p_c032            => lRc."consignee.name"
                                     );
        end loop;
      
      end if;
    
      -- Постраничный вывод данных из коллекции
    
      apex_json.open_array('data');
    
      for lRc in (select c.seq_id "seq_id",
                         to_number(c.c001) "id",
                         c.c002 "place_from",
                         c.c003 "place_to",
                         c.c004 "status",
                         to_number(c.c005) "status_id",                         
                         to_number(c.c006) "receivables",
                         to_number(c.c007) "amount",
                         to_number(c.c008) "notification_count",
                         c.c009 "cargo_name",
                         c.c010 "created_at",
                         c.c011 "date_from",
                         c.c012 "date_to",
                         c.c013 "te_type",
                         c.c014 "port_svh",
                         c.c015 "departure_country",
                         c.c016 "date_closed",
                         c.c017 "shipment_date",
                         c.c018 "unload_transhipment_plan_date",
                         c.c019 "unload_destination_plan_date",
                         c.c020 "unload_destination_fact_date",
                         c.c021 "date_dt",
                         c.c022 "date_release_dt",
                         c.c023 "dt_number",
                         c.c024 "date_export_port",
                         c.c025 "date_return_empty",
                         c.c026 "customer_delivery_date",
                         c.c027 "am_number",
                         c.c028 "fio_driver",
                         c.c029 "consignor.id",
                         c.c030 "consignor.name",
                         c.c031 "consignee.id",
                         c.c032 "consignee.name"
                  
                    from apex_collections c
                   where c.collection_name = lCollectionName
                     and c.seq_id > lOffset
                     and c.seq_id <= lOffset + lLimit) loop
      
        apex_json.open_object;
      
        apex_json.write('seq_id', lRc."seq_id", true);
        apex_json.write('id', lRc."id", true);
        apex_json.write('place_from', lRc."place_from", true);
        apex_json.write('place_to', lRc."place_to", true);
        apex_json.write('status', lRc."status", true);
        apex_json.write('status_id', lRc."status_id", true);
        apex_json.write('date_closed', lRc."date_closed",true);              
        apex_json.write('receivables', lRc."receivables", true);
        apex_json.write('amount', lRc."amount", true);
        apex_json.write('notification_count', lRc."notification_count", true);
        apex_json.write('cargo_name', lRc."cargo_name", true);
        apex_json.write('created_at', lRc."created_at", true);
        apex_json.write('date_from', lRc."date_from", true);
        apex_json.write('date_to', lRc."date_to", true);
        apex_json.write('te_type', lRc."te_type", true);
        apex_json.write('port_svh', lRc."port_svh", true);
        apex_json.write('departure_country', lRc."departure_country", true);
        apex_json.write('shipment_date', lRc."shipment_date", true);
        apex_json.write('unload_transhipment_plan_date', lRc."unload_transhipment_plan_date", true);
        apex_json.write('unload_destination_plan_date', lRc."unload_destination_plan_date", true);
        apex_json.write('unload_destination_fact_date', lRc."unload_destination_fact_date", true);
        apex_json.write('date_dt', lRc."date_dt", true);
        apex_json.write('date_release_dt', lRc."date_release_dt", true);
        apex_json.write('dt_number', lRc."dt_number", true);
        apex_json.write('date_export_port', lRc."date_export_port", true);
        apex_json.write('date_return_empty', lRc."date_return_empty", true);
        apex_json.write('customer_delivery_date', lRc."customer_delivery_date", true);
        apex_json.write('am_number', lRc."am_number", true);
        apex_json.write('fio_driver', lRc."fio_driver", true);
        
        apex_json.open_object('consignor');
        apex_json.write('id', lRc."consignor.id", true);
        apex_json.write('name', lRc."consignor.name", true);
        apex_json.close_object;
        
        apex_json.open_object('consignee');
        apex_json.write('id', lRc."consignee.id", true);
        apex_json.write('name', lRc."consignee.name", true);
        apex_json.close_object;
      
        apex_json.close_object;
      
      end loop;
    
      apex_json.close_array;
    
      -- Pager
      apex_json.open_object('pager');
    
      apex_json.write('offset', lOffset);
    
      select count(c.seq_id)
        into lColectionCount
        from apex_collections c
       where c.collection_name = lCollectionName;
    
      apex_json.write('total', lColectionCount);
    
      apex_json.close_object();
    
    end if;
  
    return lError;
  
  end;

  /*
  Вывод информации по конкретному заказу
  */
  function PrintOrder return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    --lCurrentUserId   number;
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lRc sys_refcursor;
  
    lOrderId number := null;
  
    cou number := 0; -- 17.07.2017
  
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName,
                                                          1));
  
    -- filters
    begin
      
      lOrderId := apex_json.get_number(p_path    => 'filter.id',
                                       p_default => null);
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
  
    if lIsSuccess then
    
      -- Данные по заказу
      apex_json.open_object('data');
    
      for l_c in (select *
                    from TABLE(mcsf_api.GetOrderById(pID     => lOrderId,
                                                      pClntId => lCompanyId))) loop
      
        cou := cou + 1;
        
        apex_json.write('id', l_c.id, true);
        
        apex_json.open_object('consignor');          
        rest_api_helper.PrintT_CONTRACTOR_SHORT(l_c.consignor);
        apex_json.close_object;
        
        apex_json.open_object('consignee');          
        rest_api_helper.PrintT_CONTRACTOR_SHORT(l_c.consignee);
        apex_json.close_object;
        
        apex_json.write('created_at',  to_char(l_c.created_at, PkgDefaultDateFormat), true);
        apex_json.write('date_closed',  to_char(l_c.date_closed, PkgDefaultDateFormat), true);                        
       -- apex_json.write('status', l_c.status, true);
        -- messages[]
        /*
        Пункт 4.7.2 в ответе убран параметр messages
        open lRc for
          select m.id "id",
                 m.from_mes "from_mes",
                 m.content_mes "content_mes",
                 to_char(m.created_at, PkgDefaultDateFormat) "created_at",
                 m.status "status",
                 m.order_id "order_id"
            from table(l_c.messages) m;
        apex_json.write('messages', lRc);*/
      
        -- Информация о грузе по заказу - cargo
        apex_json.open_array('cargo');      
        for elem in 1 .. l_c.cargo.count loop
          apex_json.open_object;          
          rest_api_helper.PrintT_CARGO(l_c.cargo(elem));
          apex_json.close_object;                             
        end loop;
        apex_json.close_array;      
      
        -- Информация о ТЕ - unit
        apex_json.open_object('unit');                    
        rest_api_helper.PrintT_UNIT(l_c.unit);
        apex_json.close_object; 
        
        -- Документы по заказу - doc[]
        apex_json.open_array('doc');
        for elem in 1 .. l_c.doc.count loop
          apex_json.open_object;
          rest_api_helper.PrintT_DOC(l_c.doc(elem));
          apex_json.close_object;                   
        end loop;
        apex_json.close_array;
      
        --apex_json.write('receivable_cost', l_c.receivable_cost, true);
        --apex_json.write('amount_cost', l_c.amount_cost, true);
        --apex_json.write('receivable_date', to_char(l_c.receivable_date, PkgDefaultDateFormat), true);
        --apex_json.write('receivable_status', l_c.receivable_status, true);
        apex_json.write('departure_port', l_c.departure_port, true);
        apex_json.write('departure_country', l_c.departure_country, true);
        apex_json.write('te_type', l_c.container_type, true);
        apex_json.write('container_prefix', l_c.container_prefix, true);
        apex_json.write('container_number', l_c.container_number, true);
        apex_json.write('shipment_date', to_char(l_c.date_shipment, PkgDefaultDateFormat), true);
        apex_json.write('date_transshipment', to_char(l_c.date_transshipment, PkgDefaultDateFormat), true);
        apex_json.write('date_arrival', to_char(l_c.date_arrival, PkgDefaultDateFormat), true);
        apex_json.write('date_upload', to_char(l_c.date_upload, PkgDefaultDateFormat), true);
        apex_json.write('date_export', to_char(l_c.date_export, PkgDefaultDateFormat), true);
        apex_json.write('customer_delivery_date', to_char(l_c.customer_delivery_date, PkgDefaultDateFormat), true);
        apex_json.write('date_submission', to_char(l_c.date_submission, PkgDefaultDateFormat), true);
        apex_json.write('arrival_city', l_c.arrival_city, true);
        apex_json.write('arrival_port', l_c.arrival_port, true);
       -- apex_json.write('arrival_ship', l_c.arrival_ship, true);
        apex_json.write('gtd_number', l_c.gtd_number, true);
        apex_json.write('gtd_date', to_char(l_c.gtd_date, PkgDefaultDateFormat), true);
        apex_json.write('gtd_issuance', to_char(l_c.gtd_issuance, PkgDefaultDateFormat), true);
        
        -- rummages
        apex_json.open_array('rummages');
        for elem in 1 .. l_c.rummages.count loop
          rest_api_helper.PrintT_RUMMAGE(l_c.rummages(elem));
        end loop;
        apex_json.close_array;
      
        -- invoices[]
        apex_json.open_array('invoices'); -- invoices in the order:
        for elem in 1 .. l_c.invoices.count loop
          apex_json.open_object;
          rest_api_helper.PrintT_INVOICE(l_c.invoices(elem));
          apex_json.close_object;
        end loop;
        apex_json.close_array;
        
        -- delivery_car
        apex_json.open_object('delivery_car');          
        rest_api_helper.PrintT_DELIVERY_CAR(l_c.delivery_car);
        apex_json.close_object;  
      
      end loop;
    
      apex_json.close_object;
    
      if cou = 0 then
        lError := Errors(8);
      end if;
    
    end if;
  
    return lError;
  
  end;
  
  /*
  Вывод списка документов - п.4.8.5 ТЗ на АПИ
  */
  function PrintDocs return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lCollectionName   varchar2(255) := 'DOCS';
    lCollectionExists boolean;
  
    lOffset number;
    lLimit  number;
    
    lFiltersState    varchar2(4000) := null;
    lFiltersPrevious varchar2(4000) := null;
  
    lShouldResetCollection boolean := true;
    lColectionCount        number := 0;
    
    -- Filters
    lFilter varchar2(4000);
    lQueryFilter varchar2(200);
    
    -- Sort
    lSorts varchar2(200);
    
    lXmlTemp XMLTYPE;
    lCursor sys_refcursor;
    lFileRecTemp mcsf_api_helper.t_mcsf_api_order_doc_file_rec;
    
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1));
    
    -- Filters
    begin
      
      lOffset := apex_json.get_number(p_path    => 'offset', p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit', p_default => PkgDefaultLimit);
                                      
      rest_api_helper.AddFilter('id', null, lFilter);
      
      rest_api_helper.AddFilter('order_id', null, lFilter);
      
      rest_api_helper.AddFilter('type_id', null, lFilter);
      
      rest_api_helper.AddFilter('doc_type', null, lFilter);
      
      rest_api_helper.AddFilter('type', 'doc_type', lFilter);
      
      rest_api_helper.AddFilter('doc_date', null, lFilter);
      
      rest_api_helper.AddFilter('date', 'doc_date', lFilter);
      
      rest_api_helper.AddFilter('uploaded_at', null, lFilter);
      
      rest_api_helper.AddFilter('owner', null, lFilter);
      
      rest_api_helper.AddFilter('files', null, lFilter);
      
      
      lQueryFilter := replace(apex_json.get_varchar2('data.query', null), '''', '"');
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
    
    -- Order by
    begin
      
      rest_api_helper.AddSortFilter('id', null, lSorts);
      
      rest_api_helper.AddSortFilter('order_id', null, lSorts);
      
      rest_api_helper.AddSortFilter('type_id', null, lSorts);
      
      rest_api_helper.AddSortFilter('doc_type', null, lSorts);
      
      rest_api_helper.AddSortFilter('type', 'doc_type', lSorts);
      
      rest_api_helper.AddSortFilter('doc_date', null, lSorts);
      
      rest_api_helper.AddSortFilter('date', 'doc_date', lSorts);
      
      rest_api_helper.AddSortFilter('uploaded_at', null, lSorts);
      
      rest_api_helper.AddSortFilter('owner', null, lSorts);
      
      rest_api_helper.AddSortFilter('files', null, lSorts);
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(6);
    end;
    
    -- Проверяем, изменились ли фильтры
    lFiltersPrevious := apex_util.get_preference(lCollectionName || apex_application.g_instance, lCurrentUserName);
                                                 
    lFiltersState := lCollectionName || lFilter || lQueryFilter ||  lSorts;
                     
    if lFiltersPrevious = lFiltersState then
      lShouldResetCollection := false;
    end if;
  
    apex_util.set_preference(lCollectionName || apex_application.g_instance, lFiltersState, lCurrentUserName);
    
    if lIsSuccess then
      -- Формирование коллекции
       if lShouldResetCollection then
          lCollectionExists := APEX_COLLECTION.COLLECTION_EXISTS(lCollectionName);
      
         if lCollectionExists then
            APEX_COLLECTION.DELETE_COLLECTION(lCollectionName);
         end if;
         
         APEX_COLLECTION.CREATE_COLLECTION(lCollectionName);
         
         for lRc in (select * from TABLE(mcsf_api.GetDocuments(pClntId => lCompanyId,
                                                             pFilter => lFilter,
                                                             pQueryFilter => lQueryFilter,
                                                             pSortFilter => lSorts
                                                             ))) 
         loop
           
           begin
             open lCursor for select t.id as "id", t.file_name as "file_name", t.file_size as "file_size" from table( lRc.files ) t;
              
             lXmlTemp := xmltype(lCursor);
             
             close lCursor;
           exception
             when others then
               lXmlTemp := null;
           end;
           
           APEX_COLLECTION.ADD_MEMBER(p_collection_name => lCollectionName,
                                         p_c001            => lRc.id,
                                         p_c002            => lRc.order_id,
                                         p_c003            => lRc.type_id,
                                         p_c004            => lRc.doc_type,
                                         p_c005            => to_char(lRc.doc_date,PkgDefaultDateFormat),
                                         p_c006            => to_char(lRc.uploaded_at,PkgDefaultDateFormat),
                                         p_c007            => lRc.owner,
                                         p_xmltype001      => lXmlTemp
                                         );
                                         null;
         end loop;
      end if;
      
      -- Постраничный вывод данных из коллекции
    
      apex_json.open_array('data');
      
      for lRc in (select c.seq_id "seq_id",
                         to_number(c.c001) "id",
                         to_number(c.c002) "order_id",
                         to_number(c.c003) "type_id",
                         c.c004 "doc_type",
                         c.c005 "doc_date",
                         c.c006 "uploaded_at",
                         c.c007 "owner",
                         c.xmltype001 "files"
                    from apex_collections c
                   where c.collection_name = lCollectionName
                     and c.seq_id > lOffset
                     and c.seq_id <= lOffset + lLimit) loop
        
        apex_json.open_object;
        
        apex_json.write('seq_id', lRc."seq_id", true);
        apex_json.write('id', lRc."id", true);
        apex_json.write('order_id', lRc."order_id", true);
        apex_json.write('type_id', lRc."type_id", true);
        apex_json.write('type', lRc."doc_type", true);
        apex_json.write('date', lRc."doc_date", true);
        apex_json.write('uploaded_at', lRc."uploaded_at",true);              
        apex_json.write('owner', lRc."owner", true);
        
        if lRc."files" is not null then
          
          apex_json.write('files', lRc."files", true);
          
        else
          apex_json.open_array('files');
          apex_json.close_array;
        end if;
        
        apex_json.close_object;
        
      end loop;
      
      apex_json.close_array;
      
      -- Pager
      apex_json.open_object('pager');
      
      apex_json.write('offset', lOffset);
      
      select count(c.seq_id)
        into lColectionCount
        from apex_collections c
       where c.collection_name = lCollectionName;
      
      apex_json.write('total', lColectionCount);
      
      apex_json.close_object();
      
      
    end if;
    
    return lError;
    
  end;
  
  /*
  Вывод информации по конкретному документу - п.4.8.2 ТЗ на АПИ
  */
  function PrintDoc return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lRc sys_refcursor;
  
    lDocId number := null;
    lDoc t_mcsf_api_order_doc := null;
    
  begin
    
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, PkgClientIdAttributeNumber));
    
    -- Фильтры
    begin
      
      lDocId   := apex_json.get_number('filter.id',null);
      
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
    
    if lDocId is null or lDocId <= 0 then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'id', 0);
    end if;
  
    if lIsSuccess then
      
      -- Данные по документу
      
      lDoc := mcsf_api.GetDocument(pClntId => lCompanyId, pId => lDocId);
      
      if lDoc is not null then
        
        apex_json.open_object('data');
        
        rest_api_helper.PrintT_DOC(lDoc);
      
        apex_json.close_object;
        
      else
        
        lError := Errors(8);
        
      end if;
    
    end if;
  
    return lError;
  end;
  
  /*
  Функция для обновления документов - п.4.8.1 ТЗ на АПИ
  */
  function CreateDoc return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    --lCurrentUserId   number;
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lDocId        number := null;
    lOrderId      number := null;
    lTypeId       number := null;
    lDate         date := null;
    lAuthor       varchar2(255) := null;
    lDocNumber    varchar2(255) := null;
    lDocName      varchar2(255) := null;
    lShortContent varchar2(255) := null;
    
    lDoc t_mcsf_api_order_doc := null;
  
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, PkgClientIdAttributeNumber));
  
    -- Данные
    
    begin
    
      lOrderId := apex_json.get_number(p_path => 'data.order_id', p_default => null);
      
      lTypeId  := apex_json.get_number(p_path => 'data.type_id', p_default => null);
    
      lDate := apex_json.get_date(p_path => 'data.date', p_format  => PkgDefaultDateFormat, p_default => null);
    
      lAuthor := apex_json.get_varchar2(p_path => 'data.author', p_default => null);
    
      lDocNumber := apex_json.get_varchar2(p_path => 'data.number', p_default => null);
    
      lShortContent := apex_json.get_varchar2(p_path => 'data.theme', p_default => null);
    
      lShortContent := apex_json.get_varchar2(p_path => 'data.short_content', p_default => null);
      
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(9);
        
    end;
    
    -- Проверка обязательных
    
    if lOrderId is null or lOrderId <= 0 then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'order_id', 0);
    end if;
    
    if lTypeId is null or lTypeId <= 0 then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'type_id', 0);
    end if;
  
    if lIsSuccess then
      begin
        lDocId := mcsf_api.CreateDocument(pOrdId        => lOrderId,
                                          pClntId       => lCompanyId,
                                          pDctpId       => lTypeId,
                                          pDocnumber    => lDocNumber,
                                          pDocDate      => lDate,
                                          pTheme        => lDocName,
                                          pShortContent => lShortContent,
                                          pAuthor       => lAuthor);
                                 
        if lDocId is not null and lDocId > 0 then
          lIsSuccess := true;
          
          lDoc := mcsf_api.GetDocument(pClntId => lCompanyId, pId => lDocId);
      
          if lDoc is not null then
            
            apex_json.open_object('data');
            
            rest_api_helper.PrintT_DOC(lDoc);
          
            apex_json.close_object;
            
          else
            
            lError := Errors(8);
            lIsSuccess := false;
            
          end if;
          
        else
          lIsSuccess := false;
        end if;
      
        if lIsSuccess = false then
          lError := rest_api_err('failed_create_document',
                                 'Failed create document',
                                 0);
        end if;
      
      exception
        when others then
          lError     := Errors(3);
      end;
      
    end if;
  
    return lError;
    
  end;
  
  /*
  Функция для обновления документов - п.4.8.2 ТЗ на АПИ
  */
  function UpdateDoc return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lDocId        number := null;
    lOrderId      number := null;
    lTypeId       number := null;
    lDate         date := null;
    lAuthor       varchar2(255) := null;
    lDocNumber    varchar2(255) := null;
    lDocName      varchar2(255) := null;
    lShortContent varchar2(255) := null;
  
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, PkgClientIdAttributeNumber));
  
    -- Данные
    
    begin
      
      lDocId   := apex_json.get_number(p_path => 'data.id', p_default => null);
      
      lOrderId := apex_json.get_number(p_path => 'data.order_id', p_default => null);
      
      lTypeId  := apex_json.get_number(p_path  => 'data.type_id', p_default => null);
    
      lDate := apex_json.get_date(p_path => 'data.date', p_format  => PkgDefaultDateFormat, p_default => null);
    
      lAuthor := apex_json.get_varchar2(p_path => 'data.author',  p_default => null);
    
      lDocNumber := apex_json.get_varchar2(p_path => 'data.number', p_default => null);
    
      lShortContent := apex_json.get_varchar2(p_path => 'data.theme', p_default => null);
    
      lShortContent := apex_json.get_varchar2(p_path => 'data.short_content',  p_default => null);
      
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(9);
    end;
    
    -- Проверка обязательных
    
    if lDocId is null or lDocId <= 0 then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'id', 0);
    end if;
    
    if lOrderId is null or lOrderId <= 0 then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'order_id', 0);
    end if;
    
    if lTypeId is null or lTypeId <= 0 then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'type_id', 0);
    end if;
  
    if lIsSuccess then
      begin
        lIsSuccess := mcsf_api.UpdateDocument(pClntId       => lCompanyId,
                                              pDocId        => lDocId,
                                              pDctpId       => lTypeId,
                                              pDocnumber    => lDocNumber,
                                              pDocDate      => lDate,
                                              pTheme        => lDocName,
                                              pShortContent => lShortContent,
                                              pAuthor       => lAuthor);
      
        if lIsSuccess = false then
          lError := rest_api_err('failed_update_document', 'Failed update document', 0);
        end if;
      
      exception
        when others then
          lIsSuccess := false;
          lError     := Errors(3);
      end;
      
    end if;
  
    return lError;
    
  end;
  
  /*
  Функция удаления документов - п.4.8.4 ТЗ на АПИ
  */
  function RemoveDoc return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lDocId number := null;
  
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, PkgClientIdAttributeNumber));
  
    -- Данные
    begin
      
      lDocId := apex_json.get_number(p_path => 'data.id', p_default => null);
      
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(9);
    end;
    
    -- Проверка обязательных
    
    if lDocId is null or lDocId <= 0 then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'id', 0);
    end if;
  
    if lIsSuccess then
      
      begin
        lIsSuccess := mcsf_api.RemoveDocument(pClntId => lCompanyId,
                                              pDocId  => lDocId);
      
        if lIsSuccess = false then
          lError := rest_api_err('failed_remove_document',
                                 'Failed remove document',
                                 0);
        end if;
      
      exception
        when others then
          lIsSuccess := false;
          lError     := Errors(3);
      end;
    end if;
  
    return lError;
    
  end;

  /*
  Функция для сохранения файлов - п.4.8.6 ТЗ на АПИ
  */
  function SaveFile(pDocId  in number,
                    pClntId in number,
                    pFile   in blob,
                    pMime   in varchar2,
                    pFileId out number) return rest_api_err is
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lFileId number := 0;
  
  begin
  
    if pFile is null then
      lIsSuccess := false;
      lError     := Errors(7);
    end if;
  
    if lIsSuccess then
      
      begin
      
        lFileId := mcsf_api.AddFileToDocument(pClntId   => pClntId,
                                              pDocId    => pDocId,
                                              pFileBody => pFile,
                                              pFileName => pMime);
      
        if lFileId > 0 then
          lIsSuccess := true;
          pFileId    := lFileId;
        else
          lError     := Errors(7);
          lIsSuccess := false;
        end if;
        
      exception
        when others then
          lIsSuccess := false;
          lError     := Errors(7);
      end;
    
    end if;
  
    return lError;
  
  end;
  
  /*
  Функция возвращает файл - п.4.8.7 ТЗ на АПИ
  */
  function DownloadFile(pClntId in number, pFileId in number)
    return rest_api_err is
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lFile blob := null;
  
    lFileName varchar2(255) := '';
  
  begin
  
    if pFileId is null then
      lIsSuccess := false;
      lError     := Errors(8);
    end if;
  
    if lIsSuccess then
      begin
      
        mcsf_api.GetFile(pClntId   => pClntId,
                         pFileId   => pFileId,
                         pFileBody => lFile,
                         pFileName => lFileName);
      
        if lFile is not null then
        
          sys.htp.init;
          sys.owa_util.mime_header('application/octet-stream', false, 'UTF-8');
          sys.htp.p('Content-length: ' || sys.dbms_lob.getlength(lFile));
          sys.htp.p('Content-Disposition: inline; filename="' || lFileName || '"');
          sys.owa_util.http_header_close;
        
          sys.wpg_docload.download_file(lFile);
        
        else
          lError := Errors(8);
        end if;
      
      exception
        when others then
          lError := Errors(8);
      end;
    
    end if;
  
    return lError;
  
  end;
  
  /*
  Функция удаления документов - п.4.8.6 ТЗ на АПИ
  */
  function AddFileToDoc return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lDocId number := null;
    lFile t_mcsf_api_order_doc_file;
  
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, PkgClientIdAttributeNumber));
  
    -- Данные
    begin
      
      lDocId := apex_json.get_number(p_path => 'data.doc_id', p_default => null);
      
      --lFileName :=       
      lFile := new t_mcsf_api_order_doc_file(
            null,
            apex_json.get_varchar2(p_path => 'data.file.name', p_default => null),
            apex_json.get_number(p_path => 'data.file.size', p_default => 0),
            apex_json.get_clob(p_path => 'data.file.content', p_default => null)
      );
      
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(9);
    end;
    
    -- Проверка обязательных
    
    if lDocId is null or lDocId <= 0 then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'doc_id', 0);
    end if;
    
    if lFile.file_name is null then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'file.name', 0);
    end if;
    
    if lFile.content is null then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'file.content', 0);
    end if;
  
    if lIsSuccess then
      null;
    end if;
  
    if lIsSuccess then
      lFile.id := mcsf_api.AddFileToDocument(pClntId   => lCompanyId,
                                            pDocId    => lDocId,
                                            pFileBody => mcsf_api_helper.decode_base64(lFile.content),
                                            pFileName => lFile.file_name);
      
      if lFile.id > 0 then
        lIsSuccess := true;
        
        
        for lRc in (select * from table(mcsf_api_helper.GetDocFiles(lDocId, lFile.id))) loop
          
            lFile := new t_mcsf_api_order_doc_file(lRc.id, lRc.file_name, lRc.file_size, lRc.content);
        
        end loop;  
        
      else
        lError     := Errors(7);
        lIsSuccess := false;
      end if;
                         
      if lIsSuccess then
        apex_json.open_object('data');
        rest_api_helper.PrintT_FILE(lFile);
        apex_json.close_object;
      else
        lIsSuccess := false;
      end if;
      
    end if;
  
    return lError;
    
  end;

  /*
  Вывод списка файлов - п.4.8.7 ТЗ на АПИ
  */
  function PrintFiles return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    
    lCurrentUserName varchar2(255);
    lCompanyId       number;
    
    lDocId number;
    lFileId number;
    lOrderId number;
    lContent boolean := true;
    
    lFile t_mcsf_api_order_doc_file;
    
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1));
    
    -- Filters
    begin
      
      lDocId := apex_json.get_number('filter.doc_id', apex_json.get_number('filter.doc_id.value', null));
      lFileId := apex_json.get_number('filter.file_id', apex_json.get_number('filter.file_id.value', null));
      lOrderId := apex_json.get_number('filter.order_id', apex_json.get_number('filter.order_id.value', null));
      
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
    
    -- Проверка обязательных
    
    if lDocId is null and lFileId is null and lOrderId is null then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'doc_id or file_id or order_id', 0);
    end if;
    
    if lIsSuccess then
      
      apex_json.open_array('data');
      
      for lRc in (select * from table(mcsf_api_helper.GetDocFiles(pDocId => lDocId, 
                                                                  pFileId => lFileId, 
                                                                  pOrderId => lOrderId,
                                                                  pContent => 1,
                                                                  pClientId => lCompanyId
                                                                  ))) loop
        
          lFile := new t_mcsf_api_order_doc_file(lRc.id, lRc.file_name, lRc.file_size, lRc.content);
          
          apex_json.open_object;
          rest_api_helper.PrintT_FILE(lFile, TRUE);
          apex_json.close_object;
          
      end loop;
      
      apex_json.close_array;
       
    end if;
    
    return lError;
  
  end;

  /*
  Вывод ссылка на архив с документами - п.4.8.8 ТЗ на АПИ
  */
  function PrintFilesZipLink return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    
    lCurrentUserName varchar2(255);
    lCompanyId       number;
    
    lDocId number;
    lFileId number;
    lOrderId number;
    lTypeId number;
    
    lLinkToken varchar2(80) := dbms_random.string('A', 40);
    
    lFile t_mcsf_api_order_doc_zip;
    
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1));
    
    -- Filters
    begin
      
      lDocId := apex_json.get_number('filter.doc_id', apex_json.get_number('filter.doc_id.value', null));
      lFileId := apex_json.get_number('filter.file_id', apex_json.get_number('filter.file_id.value', null));
      lOrderId := apex_json.get_number('filter.order_id', apex_json.get_number('filter.order_id.value', null));
      lTypeId := apex_json.get_number('filter.type_id', apex_json.get_number('filter.type_id.value', null));
      
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
    
    -- Проверка обязательных
    
    if lOrderId is null then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'order_id', 0);
    end if;
    
    if lIsSuccess then
      
      lFile := mcsf_api_helper.GetDocZip(pDocId => lDocId,
                                         pOrderId => lOrderId,
                                         pFileId => lFileId,
                                         pTypeId => lTypeId,
                                         pContent => 0,
                                         pClientId => lCompanyId);
      if lFile is null then
        
         lIsSuccess := false;
         lError := Errors(8);
        
      end if; 
      
    end if;
    
    if lIsSuccess then
      
      insert into mcsf_api_files_links
        (link_token, create_date, session_id, token, params)
      values
        (lLinkToken,
         sysdate,
         apex_application.g_instance,
         APEX_UTIL.get_preference('TOKEN', APEX_CUSTOM_AUTH.GET_USERNAME),
         lOrderId || ':' || lDocId || ':' || lFileId || ':' || lTypeId);
         
      commit;
    
      apex_json.open_object('data');
      
      apex_json.write('link', lLinkToken, true);                                 
        
      apex_json.close_object;
      
    end if;
    
    return lError;
  
  end;
  
  /*
  Функция возвращает zip файл - п.4.8.8 ТЗ на АПИ
  */
  function DownloadZipFile
    return rest_api_err is
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    
    lCurrentUserName varchar2(255);
    lCompanyId       number;
    
    lDocId number;
    lFileId number;
    lOrderId number;
    lTypeId number;
    
    lSession varchar2(255);
    lToken varchar2(255);
    
    lLinkToken varchar2(40);
    lParams varchar2(255);
    
    lFile t_mcsf_api_order_doc_zip;
    
    lVcArr2    APEX_APPLICATION_GLOBAL.VC_ARR2;
  
  begin
    
    -- Filters
    begin
      
      lLinkToken := apex_json.get_varchar2('filter.link_token', apex_json.get_varchar2('filter.link_token.value', null));
      
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
    
    -- Проверка обязательных
    
    if lLinkToken is null then
      lIsSuccess := false;
      lError := rest_api_err('required_missing', 'link_token', 0);
    end if;
    
    if lIsSuccess then
      begin
      
        select t.session_id, t.token, t.params into lSession, lToken, lParams from mcsf_api_files_links t where t.link_token = lLinkToken;
        
      exception
        when others then
          lIsSuccess := false;
          lError     := Errors(8);
      end;
    end if;
    
    if lIsSuccess then
      if IsSessionValid(lSession, lToken) then
        begin
          lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
          lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, PkgClientIdAttributeNumber));
        
        exception
          when others then
            lIsSuccess     := false;
            lError         := Errors(9);
            lError.message := sqlerrm;
        end;
        
      else
        lIsSuccess := false;
        lError     := Errors(2);
      end if;
      
    end if;
    
    if lIsSuccess then
      lVcArr2 := APEX_UTIL.STRING_TO_TABLE(lParams);
      
      if lVcArr2.count = 4 then
        
        lOrderId := lVcArr2(1);
        lDocId := lVcArr2(2);
        lFileId := lVcArr2(3);
        lTypeId := lVcArr2(4);
      
      end if;
      
    end if;
    
    if lIsSuccess then
      
      lFile := mcsf_api_helper.GetDocZip(pDocId => lDocId,
                                         pOrderId => lOrderId,
                                         pFileId => lFileId,
                                         pTypeId => lTypeId,
                                         pContent => 1,
                                         pClientId => lCompanyId);
      if lFile is null then
        
         lIsSuccess := false;
         lError := Errors(8);
        
      end if; 
      
    end if;
  
    if lIsSuccess then
      
      begin
        
        sys.htp.init;
        sys.owa_util.mime_header('application/octet-stream', false, 'UTF-8');
        sys.htp.p('Content-length: ' || sys.dbms_lob.getlength(lFile.content));
        sys.htp.p('Content-Disposition: attachment; filename="' || lFile.file_name || '"');
        sys.owa_util.http_header_close;
        
        sys.wpg_docload.download_file(lFile.content);
      
      exception
        when others then
          apex_json.write('exception', SQLERRM, true);
          lError := Errors(8);
      end;
    
    end if;
  
    return lError;
  
  end;

  
  /*
  Файловый API
  */
  procedure ApiFile(pSession  in varchar2,
                    pToken    in varchar2,
                    pDocId    in number default null,
                    pFileId   in number default null,
                    pFileBody in blob default null,
                    pMime     in varchar2 default null) is
    lWorkspaceId number;
  
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lFileId number := 0;
  
    lMethod varchar2(10) := 'post';
  begin
    begin
      lWorkspaceId := apex_util.find_security_group_id(p_workspace => WorkspaceName);
      apex_util.set_security_group_id(p_security_group_id => lWorkspaceId);
    
      if pFileId is not null then
        lMethod := 'get';
      end if;
    
    exception
      when others then
        lIsSuccess     := false;
        lError         := Errors(3);
        lError.message := sqlerrm;
    end;
    
    if IsSessionValid(pSession, pToken) then
      
      begin
        lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
        lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, PkgClientIdAttributeNumber));
      
      exception
        when others then
          lIsSuccess     := false;
          lError         := Errors(9);
          lError.message := sqlerrm;
      end;
      
    else
      lIsSuccess := false;
      lError     := Errors(2);
    end if;
  
    if lIsSuccess then
      CASE lMethod
      
        WHEN 'get' THEN
        lError     := Errors(2);
          lError := DownloadFile(pClntId => lCompanyId,
                                 pFileId => pFileId);
          if lError.success != 1 then
            lIsSuccess := false;
          end if;
        
          if lIsSuccess != true then
            apex_json.initialize_clob_output;
            apex_json.open_object;
          
            apex_json.write('success', lIsSuccess);
          
            PrintErrorJson(lError);
          
            apex_json.close_object;
          
            HtpPrn(APEX_JSON.get_clob_output);
          
            apex_json.free_output;
          end if;
        
        WHEN 'post' THEN
        
          apex_json.initialize_clob_output;
          apex_json.open_object;
        
          lError := SaveFile(pDocId  => pDocId,
                             pClntId => lCompanyId,
                             pFile   => pFileBody,
                             pMime   => pMime,
                             pFileId => lFileId);
          if lError.success = 1 then
            lIsSuccess := true;
            apex_json.open_object('data');
            apex_json.write('id', lFileId, true);
            apex_json.close_object;
          else
            lIsSuccess := false;
          end if;
        
          apex_json.write('success', lIsSuccess);
        
          if lIsSuccess != true then
            PrintErrorJson(lError);
          end if;
        
          apex_json.close_object;
        
          HtpPrn(APEX_JSON.get_clob_output);
        
          apex_json.free_output;
        
        ELSE
          lIsSuccess := false;
          lError     := Errors(4);
        
      END CASE;
    else
      apex_json.initialize_clob_output;
      apex_json.open_object;
          
      apex_json.write('success', lIsSuccess);
          
      PrintErrorJson(lError);
          
      apex_json.close_object;
          
      HtpPrn(APEX_JSON.get_clob_output);
          
      apex_json.free_output;
    end if;
  end;
  
  /*
  Вывод списка стран
  */
  function PrintCountryList return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOffset number;
    lLimit  number;
  
    lColectionCount number := 0;
  
  begin
  
    -- filters
    begin
      lOffset := apex_json.get_number(p_path    => 'offset',
                                      p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit',
                                      p_default => PkgDefaultLimit);
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
  
    if lIsSuccess then
      apex_json.open_array('data');
    
      for l_c in (select *
                    from (select ROWNUM seq_id, t.*
                            from TABLE(mcsf_api.СountriesDic) t) c
                   where c.seq_id > lOffset
                     and c.seq_id <= lOffset + lLimit) loop
      
        apex_json.open_object;
      
        apex_json.write('seq_id', l_c.seq_id, true);
        apex_json.write('id', l_c.id, true);
        apex_json.write('name', l_c.def, true);
      
        apex_json.close_object;
      end loop;
    end if;
  
    apex_json.close_array;
  
    -- Pager
    apex_json.open_object('pager');
  
    apex_json.write('offset', lOffset);
  
    select count(t.id)
      into lColectionCount
      from TABLE(mcsf_api.СountriesDic) t;
  
    apex_json.write('total', lColectionCount);
  
    apex_json.close_object();
  
    return lError;
  end;

  /*
  Вывод списка регионов
  */
  function PrintRegionList return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOffset number;
    lLimit  number;
  
    lColectionCount number := 0;
  
  begin
  
    -- filters
    begin
      lOffset := apex_json.get_number(p_path    => 'offset',
                                      p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit',
                                      p_default => PkgDefaultLimit);
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
  
    if lIsSuccess then
      apex_json.open_array('data');
    
      for l_c in (select *
                    from (select ROWNUM seq_id, t.*
                            from TABLE(mcsf_api.RegionsDic) t) c
                   where c.seq_id > lOffset
                     and c.seq_id <= lOffset + lLimit) loop
      
        apex_json.open_object;
      
        apex_json.write('seq_id', l_c.seq_id, true);
        apex_json.write('id', l_c.id, true);
        apex_json.write('name', l_c.region_name, true);
      
        apex_json.close_object;
      end loop;
    end if;
  
    apex_json.close_array;
  
    -- Pager
    apex_json.open_object('pager');
  
    apex_json.write('offset', lOffset);
  
    select count(t.id)
      into lColectionCount
      from TABLE(mcsf_api.RegionsDic) t;
  
    apex_json.write('total', lColectionCount);
  
    apex_json.close_object();
  
    return lError;
  end;

  /*
  Вывод списка городов
  */
  function PrintCityList return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOffset number;
    lLimit  number;
  
    lColectionCount number := 0;
  
  begin
  
    -- filters
    begin
      lOffset := apex_json.get_number(p_path    => 'offset',
                                      p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit',
                                      p_default => PkgDefaultLimit);
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
  
    if lIsSuccess then
      apex_json.open_array('data');
    
      for l_c in (select *
                    from (select ROWNUM seq_id, t.*
                            from TABLE(mcsf_api.CitiesDic) t) c
                   where c.seq_id > lOffset
                     and c.seq_id <= lOffset + lLimit) loop
      
        apex_json.open_object;
      
        apex_json.write('seq_id', l_c.seq_id, true);
        apex_json.write('id', l_c.id, true);
        apex_json.write('name', l_c.def, true);
      
        apex_json.close_object;
      end loop;
    end if;
  
    apex_json.close_array;
  
    -- Pager
    apex_json.open_object('pager');
  
    apex_json.write('offset', lOffset);
  
    select count(t.id)
      into lColectionCount
      from TABLE(mcsf_api.CitiesDic) t;
  
    apex_json.write('total', lColectionCount);
  
    apex_json.close_object();
  
    return lError;
  end;

  /*
  Вывод списка типов документов
  */
  function PrintDocTypList return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOffset number;
    lLimit  number;
  
    lColectionCount number := 0;
  
  begin
  
    -- filters
    begin
      lOffset := apex_json.get_number(p_path    => 'offset',
                                      p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit',
                                      p_default => PkgDefaultLimit);
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
  
    if lIsSuccess then
      apex_json.open_array('data');
    
      for l_c in (select *
                    from (select ROWNUM seq_id, t.*
                            from TABLE(mcsf_api.DocTypesDic) t) c
                   where c.seq_id > lOffset
                     and c.seq_id <= lOffset + lLimit) loop
      
        apex_json.open_object;
      
        apex_json.write('seq_id', l_c.seq_id, true);
        apex_json.write('id', l_c.id, true);
        apex_json.write('name', l_c.def, true);
      
        apex_json.close_object;
      end loop;
    end if;
  
    apex_json.close_array;
  
    -- Pager
    apex_json.open_object('pager');
  
    apex_json.write('offset', lOffset);
  
    select count(t.id)
      into lColectionCount
      from TABLE(mcsf_api.DocTypesDic) t;
  
    apex_json.write('total', lColectionCount);
  
    apex_json.close_object();
  
    return lError;
  end;
  
  /*
  Вывод справочника статусов
  */
  function PrintStatusesDic return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOffset number;
    lLimit  number;
  
    lColectionCount number := 0;
  
  begin
  
    -- filters
    begin
      lOffset := apex_json.get_number(p_path    => 'offset', p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit', p_default => PkgDefaultLimit);
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
  
    if lIsSuccess then
      apex_json.open_array('data');
    
      for l_c in (select *
                    from (select ROWNUM seq_id, t.*
                            from TABLE(mcsf_api.StatusesDic) t) c
                   where c.seq_id > lOffset
                     and c.seq_id <= lOffset + lLimit) loop
      
        apex_json.open_object;
      
        apex_json.write('seq_id', l_c.seq_id, true);
        apex_json.write('id', l_c.id, true);
        apex_json.write('name', l_c.name, true);
      
        apex_json.close_object;
      end loop;
    end if;
  
    apex_json.close_array;
  
    -- Pager
    apex_json.open_object('pager');
  
    apex_json.write('offset', lOffset);
  
    select count(t.id)
      into lColectionCount
      from TABLE(mcsf_api.DocTypesDic) t;
  
    apex_json.write('total', lColectionCount);
  
    apex_json.close_object();
  
    return lError;
  end;

  -- Ю.К. 23.06.2017
  -- 4.8.5 Получение коллекции
  -- Название операции: orders_docs
  function PrintDocs_depricated return rest_api_err is
    lIsSuccess       boolean := true;
    lError           rest_api_err := Errors(1);
    lCurrentUserName varchar2(255);
    lCompanyId       number;
    --lRc sys_refcursor;
    --lDocId number := null;
    --lDocs mcsf_api.tbl_docs := null;
    lOffset       number;
    lLimit        number;
    v_filter_wrd  varchar2(2000) := null; -- atomic filter word
    v_filter_str  varchar2(2000) := null; -- filter string: ...str := concat(...wrd, ' and ')
    v_type_id_typ varchar2(20);
    v_type_id_val varchar2(200); -- may be CSV
    v_ord_id_typ  varchar2(20);
    v_ord_id_val  varchar2(200); -- may be CSV
    v_date_typ    varchar2(20);
    v_date_val    varchar2(200); -- may be CSV
  
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName,
                                                          1));
  
    -- Filters:
    begin
      lOffset := apex_json.get_number(p_path    => 'offset',
                                      p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit',
                                      p_default => PkgDefaultLimit);
      -- Document Type:
      v_type_id_typ := apex_json.get_varchar2(p_path    => 'filter.type_id.type',
                                              p_default => null);
      v_type_id_val := apex_json.get_varchar2(p_path    => 'filter.type_id.value',
                                              p_default => null);
      if v_type_id_val is not null then
        -- typ MAY BE null, '=' will be taken
        v_filter_wrd := rest_api_helper.make_filter_string_depricated(p_col   => 'dctp_id',
                                                           p_type  => v_type_id_typ,
                                                           p_value => v_type_id_val);
        if instr(v_filter_wrd, 'Error') != 0 then
          return Errors(5);
        else
          v_filter_str := v_filter_str || ' and (' || v_filter_wrd || ')'; -- Doc Type Filtering included
        end if;
      end if; -- v_type_id_val is not null.
      -- Order ID:
      v_ord_id_typ := apex_json.get_varchar2(p_path    => 'filter.order_id.type',
                                             p_default => null);
      v_ord_id_val := apex_json.get_varchar2(p_path    => 'filter.order_id.value',
                                             p_default => null);
      if v_ord_id_val is not null then
        -- typ MAY BE null, '=' will be taken
        v_filter_wrd := rest_api_helper.make_filter_string_depricated(p_col   => 'ord_id',
                                                           p_type  => v_ord_id_typ,
                                                           p_value => v_ord_id_val);
        if instr(v_filter_wrd, 'Error') != 0 then
          return Errors(5);
        else
          v_filter_str := v_filter_str || ' and (' || v_filter_wrd || ')'; -- Ord ID Filtering included
        end if;
      end if; -- v_ord_id_val is not null.
      -- Doc Date:
      v_date_typ := apex_json.get_varchar2(p_path    => 'filter.date.type',
                                           p_default => null);
      v_date_val := apex_json.get_varchar2(p_path    => 'filter.date.value',
                                           p_default => null);
      if v_date_val is not null then
        -- typ MAY BE null, '=' will be taken
        v_filter_wrd := rest_api_helper.make_filter_string_depricated(p_col   => 'doc_date',
                                                           p_type  => v_date_typ,
                                                           p_value => v_date_val);
        if instr(v_filter_wrd, 'Error') != 0 then
          return Errors(5);
        else
          v_filter_str := v_filter_str || ' and (' || v_filter_wrd || ')'; -- Doc Date Filtering included
        end if;
      end if; -- v_date_val is not null.
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end; -- Filters.
    -- ToDo:
    -- Create MCSF_API function: get documents by (Company ID, Filter String, Offset and Limit)
    -- Call and fetch this function
    if lIsSuccess then
      -- Данные по документу
      apex_json.open_array('data');
      for c in (select *
                  from table(mcsf_api.fn_orders_docs_depricated(p_clnt_id       => lCompanyId,
                                                     p_filter_string => v_filter_str,
                                                     p_offset        => lOffset,
                                                     p_limit         => lLimit))) loop
        -- Copy from single doc function and place in fetch cycle:
        -- Doc attributes -> JSON
        apex_json.open_object;
        rest_api_helper.PrintT_DOCS_depricated(c);
        -- Attached files -> JSON
        apex_json.open_array('files');
        for c1 in (select *
                     from table(mcsf_api.fn_doc_files(p_doc_id => c.id)) -- проверка по компании не нужна, документы уже отобраны.
                   ) loop
          apex_json.open_object;
          rest_api_helper.PrintT_FILES_depricated(c1);
          apex_json.close_object;
        end loop;
        apex_json.close_array;
        apex_json.close_object;
      end loop;
      apex_json.close_array;
    end if;
    return lError;
  end;

  /*
   Вывод информации по компании
  */
  function Companies return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName,1));
    if lIsSuccess then
      
      -- Данные по компании
      apex_json.open_object('data');
      
      for lRc in (select * from TABLE(mcsf_api.GetCompanies(pClntId => lCompanyId))) loop
        
        apex_json.write('id', lRc.id, true);
        apex_json.write('name', lRc.client_name, true);
        apex_json.write('phone', lRc.phone, true);        
        apex_json.write('plan', lRc.plan, true);
        
        -- Contacts - Массив контактныхх лиц
        apex_json.open_array('contacts');
        
        for lRcContacts in (select * from table(mcsf_api.GetCompanyContacts(pClntId => lCompanyId))) loop
        
            apex_json.open_object;
            apex_json.write('fio', lRcContacts.fio ,true);
            apex_json.write('job', lRcContacts.job ,true);
            apex_json.write('phone', lRcContacts.phone ,true);
            apex_json.write('mobile', lRcContacts.mobile ,true);
            apex_json.close_object;
        
        end loop;
        
        apex_json.close_array;
       
        -- Currency - данные о задолженности компании во всех валютах
        apex_json.open_array('sum');
        
        for lRcDolg in (select * from table(mcsf_api.GetCompanyDolg(pClntId => lCompanyId))) loop
                
            apex_json.open_object;
            apex_json.write('currency', lRcDolg.currency, true);
            apex_json.write('value', lRcDolg.debet, true);
            apex_json.close_object;
        
        end loop;
        
        apex_json.close_array;
          
        apex_json.write('total_orders', lRc.total_orders, true);
      end loop;
      
      apex_json.close_object;
      
    end if;
    return lError;
  end;

  -- =========================================================================================    
  -- Функция(и) для отчетов и графиков

  -- Отчет о грузах п.4.14.2 в ТЗ на разработку АПИ (операция report_order)
  -- Ю.К. 24.03.2017
  function report_order return rest_api_err is
    lIsSuccess       boolean := true;
    lError           rest_api_err := Errors(1);
    lCurrentUserName varchar2(255);
    lCompanyId       number;
    lQuant           varchar2(50);
    lStart           date;
    lStop            date;
    isQuantOK        number := 0; -- проверка слова управления группировкой: {'year'|'month'|'week'|'day'}
    lTotalOrders     number := 0;
    lActiveOrders    number := 0;
    lClosedOrders    number := 0;
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName,
                                                          1));
    if lIsSuccess then
      -- Взятие параметров из JSON запроса:
      begin
        lQuant := apex_json.get_varchar2(p_path    => 'data.grouped_by',
                                         p_default => null);
        -- Проверка корректности кванта группировки:
        select decode(lQuant, 'year', 1, 'month', 1, 'week', 1, 'day', 1, 0)
          into isQuantOK
          from dual;
        if isQuantOK = 0 then
          lIsSuccess := false;
          return Errors(5);
        end if; -- КАК ПРАВИЛЬНО ОТВЕТИТЬ ОБ ОШИБКЕ УПРАВЛЕНИЯ ГРУППИРОВКОЙ?
      
        lStart := apex_json.get_date(p_path    => 'filter.date_start',
                                     p_format  => PkgDefaultDateFormat,
                                     p_default => null);
        lStop  := apex_json.get_date(p_path    => 'filter.date_end',
                                     p_format  => PkgDefaultDateFormat,
                                     p_default => null);
      exception
        when others then
          lIsSuccess := false;
          return Errors(5);
      end;
      -- параметры получены.
      -- Формирование JSON отклика:
      apex_json.open_object('data'); --  "data": {
      apex_json.open_array('datasets'); --    "datasets": [
      apex_json.open_object; --      {
      apex_json.write('label', '0'); --        "label": "0",
      apex_json.open_array('data'); --        "data": [
      for c in (select d, n1, n2, n3
                  from table(SBC.mcsf_api_test.ReportOrder( -- date, total, active, closed
                                                           pClntId => lCompanyId,
                                                           pQuant  => lQuant,
                                                           pStart  => lStart,
                                                           pStop   => lStop))
                 order by 1) loop
        apex_json.open_object; --              {    
        apex_json.write('x', c.d); --                "x":  2016-02-01,
        apex_json.write('y', c.n1, true); --                "y":  20,
        apex_json.close_object; --              }      
        lTotalOrders  := lTotalOrders + c.n1;
        lActiveOrders := lActiveOrders + c.n2;
        lClosedOrders := lClosedOrders + c.n3;
      end loop;
      apex_json.close_array; --        ] -- "data"
      apex_json.close_object; --      }
      apex_json.close_array; --    ], -- "datasets"
      apex_json.write('total_orders', lTotalOrders); --    "total_orders": 1234,
      apex_json.write('active_orders', lActiveOrders); --    "active_orders": 923,
      apex_json.write('closed_orders', lClosedOrders); --    "closed_orders": 311
      apex_json.close_object; --  } -- "data"
    end if;
    return lError;
  end report_order;

  --*********************************************************************************************************************
  -- Информация о контрагентах (contractor)
  --*********************************************************************************************************************

  -- Данные о контрагенте п.4.3.1 в ТЗ на разработку АПИ (операция contractors_get)
  -- Ю.К. 14.04.2017
  /*
    "data": {
      // Просим почтовый адрес
      "address_type": 1,
      // Просим нужного контакта
      "person_for": "site"
    },
    "filter": {
      "id": 123
    }
  */
  function contractors_get return rest_api_err is
    lIsSuccess   boolean := true;
    lError       rest_api_err := Errors(1);
    lAddressType number; -- не поддерживаем
    lPersonFor   varchar2(200); -- не поддерживаем
    lClientId    number; -- sbc.clients.clnt_id
    c            SBC.mcsf_api.t_contractor;
  begin
    if lIsSuccess then
      -- Взятие параметров из JSON запроса:
      begin
        lClientId := apex_json.get_number(p_path    => 'filter.id',
                                          p_default => null); -- надо ли здесь про NULL?
      exception
        when others then
          lIsSuccess := false;
          return Errors(5);
      end;
      -- параметры получены.
      -- Формирование JSON отклика:
      c := SBC.mcsf_api.ContractorsGet(pClntId => lClientId); -- contact record (cont_rec) pick-up.
      apex_json.open_object('data'); --  "data": {
      apex_json.write('id', c.id); --    "id":  123, -- NOT NULL, поскольку дан в запросе; остальные могут быть NULL, если вообще нет данных
      apex_json.write('name', c.name, true); --    "name": "Horns and hooves ltd",
      apex_json.write('address', c.address, true); --    "address": "Russia, Tyumen, itd",    
      apex_json.write('address_type', c.address_type, true); --    "address_type": "post", -- не поддерживаем    
      apex_json.write('type', c.type, true); --    "type": 1,    
      apex_json.write('city_id', c.city_id, true); --    "city_id": 1,
      apex_json.write('city_name', c.city_name, true); --    "city_name": "Tyumen",
      apex_json.write('person_id', c.person_id, true); --    "person_id": 321,
      apex_json.write('person_phone', c.person_phone, true); --    "person_phone": "89998887766",
      apex_json.write('person_email', c.person_email, true); --    "person_email": "aaa@bbb.ccc",
      apex_json.write('person_name', c.person_name, true); --    "person_name": "Иванов Иван Иванович",
      apex_json.write('person_for', c.person_for, true); --    "person_for": "site" -- не поддерживаем
      apex_json.close_object; --  } -- "data"    
    end if;
    return lError;
  end contractors_get;

  -- Коллекции контрагентов п.4.3.2 в ТЗ на разработку АПИ (операция contractors)
  -- Ю.К. 17.04.2017
  /*
  Request sample:
  "filter": {
      "id": {
        "type": ">",
        "value": 10
      },
      "type": 1,
      "name": {
        "type": "like",
        "value": "tes%"
      }
    }
  */
  function contractors return rest_api_err is
    lIsSuccess       boolean := true;
    lError           rest_api_err := Errors(1);
    lOffset          number;
    lLimit           number;
    lIdKey           number;
    lIdOpr           varchar2(5);
    lTypeKey         number;
    lNameKey         varchar2(2000);
    lNameOpr         varchar2(200);
    lCollectionCount number := 0;
  begin
    if lIsSuccess then
      -- Взятие параметров из JSON запроса:
      begin
        lOffset := apex_json.get_number(p_path    => 'offset',
                                        p_default => PkgDefaultOffset);
        lLimit  := apex_json.get_number(p_path    => 'limit',
                                        p_default => PkgDefaultLimit);
        if apex_json.does_exist(p_path => 'filter') then
          lIdKey   := apex_json.get_number(p_path    => 'filter.id.value',
                                           p_default => null);
          lIdOpr   := apex_json.get_varchar2(p_path    => 'filter.id.type',
                                             p_default => '=');
          lTypeKey := apex_json.get_number(p_path    => 'filter.type',
                                           p_default => null);
          lNameKey := apex_json.get_varchar2(p_path    => 'filter.name.value',
                                             p_default => null);
          lNameOpr := apex_json.get_varchar2(p_path    => 'filter.name.type',
                                             p_default => 'like');
        else
          lIdKey   := null;
          lIdOpr   := '=';
          lTypeKey := null;
          lNameKey := null;
          lNameOpr := 'like';
        end if;
      exception
        when others then
          lIsSuccess := false;
          return Errors(5);
      end;
      -- параметры получены.
      -- Формирование JSON отклика:
      apex_json.open_array('data'); --  "data": [
      for c in (select rownum as seq_id, id, name, type, total_cou as cou
                  from table(SBC.mcsf_api.Contractors(p_id_key   => lIdKey,
                                                      p_id_opr   => lIdOpr,
                                                      p_type_key => lTypeKey,
                                                      p_name_key => lNameKey,
                                                      p_name_opr => lNameOpr,
                                                      p_limit    => lLimit,
                                                      p_offset   => lOffset))
                 order by name) loop
        apex_json.open_object; --   {    
        apex_json.write('seq_id', c.seq_id); --    sequential number;
        apex_json.write('id', c.id); --    "id":  123, -- NOT NULL;
        apex_json.write('name', c.name, true); --    "name": "Horns and hooves ltd",
        apex_json.write('type', c.type, true);
        apex_json.close_object; --   }
        lCollectionCount := c.cou;
      end loop;
      apex_json.close_array; --  ] -- "data".
    
      if lCollectionCount = 0 then
        lIsSuccess := false;
        return Errors(8); -- Not found.
      end if;
      -- Pager
      apex_json.open_object('pager');
      apex_json.write('offset', lOffset);
      apex_json.write('total', lCollectionCount);
      apex_json.close_object;
    
    end if;
    return lError;
  end contractors;

  -- Адрес доставки. Просмотр п.4.4.2 в ТЗ на разработку АПИ (операция delivery_points_get)
  -- Ю.К. 18.04.2017
  function delivery_points_get return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
    lId        number;
    c          SBC.mcsf_api.t_delivery_point;
  begin
    if lIsSuccess then
      -- Взятие параметров из JSON запроса:
      begin
        --lId := apex_json.get_number(p_path => 'data.id', p_default => null);
        lId := apex_json.get_number(p_path    => 'filter.id',
                                    p_default => null); -- 17.07.2017 изм. ТЗ
      exception
        when others then
          lIsSuccess := false;
          return Errors(5);
      end;
      -- параметры получены.
      -- Формирование JSON отклика:
      c := SBC.mcsf_api.DeliveryPointsGet(p_id => lId); -- Delivery Point record pick-up.
      if c.id is null then
        lIsSuccess := false;
        return Errors(8);
      end if; -- Not Found, 17.07.2017
      apex_json.open_object('data'); --  "data": {
      apex_json.write('id', c.id); --    "id":  123, -- NOT NULL, поскольку дан в запросе; остальные могут быть NULL, если вообще нет данных
      apex_json.write('address', c.address, true); --    "address": "...",
      apex_json.write('phone', c.phone, true); --    "phone": "...",
      apex_json.write('email', c.email, true); --    "email": "...",
      apex_json.write('name', c.name, true); --    "name": "...",
      apex_json.close_object;
    end if;
    return lError;
  end delivery_points_get;

  -- Адрес доставки. Получение коллекции п.4.4.5 в ТЗ на разработку АПИ (операция delivery_points)
  -- Ю.К. 20.04.2017
  function delivery_points return rest_api_err is
    lIsSuccess       boolean := true;
    lError           rest_api_err := Errors(1);
    lOffset          number;
    lLimit           number;
    lIdKey           number;
    lIdOpr           varchar2(5);
    lNameKey         varchar2(2000);
    lNameOpr         varchar2(200);
    lAddrKey         varchar2(2000);
    lAddrOpr         varchar2(200);
    lPhoneKey        varchar2(2000);
    lPhoneOpr        varchar2(200);
    lEmailKey        varchar2(2000);
    lEmailOpr        varchar2(200);
    ord_cou          number := 0;
    i                number;
    lSortLine        varchar2(2000) := null;
    lCollectionCount number := 0;
  begin
    if lIsSuccess then
      -- Взятие параметров из JSON запроса:
      begin
        lOffset := apex_json.get_number(p_path    => 'offset',
                                        p_default => PkgDefaultOffset);
        lLimit  := apex_json.get_number(p_path    => 'limit',
                                        p_default => PkgDefaultLimit);
        if apex_json.does_exist(p_path => 'filter') then
          lIdKey    := apex_json.get_number(p_path    => 'filter.id.value',
                                            p_default => null);
          lIdOpr    := apex_json.get_varchar2(p_path    => 'filter.id.type',
                                              p_default => '=');
          lNameKey  := apex_json.get_varchar2(p_path    => 'filter.name.value',
                                              p_default => '%');
          lNameOpr  := apex_json.get_varchar2(p_path    => 'filter.name.type',
                                              p_default => 'like');
          lAddrKey  := apex_json.get_varchar2(p_path    => 'filter.address.value',
                                              p_default => '%');
          lAddrOpr  := apex_json.get_varchar2(p_path    => 'filter.address.type',
                                              p_default => 'like');
          lPhoneKey := apex_json.get_varchar2(p_path    => 'filter.phone.value',
                                              p_default => '%');
          lPhoneOpr := apex_json.get_varchar2(p_path    => 'filter.phone.type',
                                              p_default => 'like');
          lEmailKey := apex_json.get_varchar2(p_path    => 'filter.email.value',
                                              p_default => '%');
          lEmailOpr := apex_json.get_varchar2(p_path    => 'filter.email.type',
                                              p_default => 'like');
        else
          lIdKey    := null;
          lIdOpr    := '=';
          lNameKey  := '%';
          lNameOpr  := 'like';
          lAddrKey  := '%';
          lAddrOpr  := 'like';
          lPhoneKey := '%';
          lPhoneOpr := 'like';
          lEmailKey := '%';
          lEmailOpr := 'like';
        end if;
        /*
        ATTENTION!!!
        Spec (wrong):
          "order": {
            "id": "asc",
            "name": "asc",
            "address": "asc",
            "phone": "asc",
            "email": "asc"
          }
        Assumed (must be positioned, i.e. array):
          "order": [
            "id asc",
            "name asc",
            "address asc",
            "phone asc",
            "email asc"
          ]
        */
        ord_cou := apex_json.get_count(p_path => 'order');
        if ord_cou > 0 then
          for i in 1 .. ord_cou loop
            lSortLine := lSortLine || ', ' ||
                         apex_json.get_varchar2(p_path => 'order[%d]',
                                                p0     => i);
          end loop;
        else
          lSortLine := 'id asc';
        end if;
        lSortLine := ltrim(lSortLine, ', ');
      exception
        when others then
          lIsSuccess := false;
          return Errors(5);
      end;
      -- параметры получены.      
      apex_json.open_array('data'); --  "data": [
      for c in (select rownum    as seq_id,
                       total_cou as cou,
                       id,
                       address,
                       phone,
                       email,
                       name
                  from table(SBC.mcsf_api.delivery_points(p_id_key    => lIdKey,
                                                          p_id_opr    => lIdOpr,
                                                          p_name_key  => lNameKey,
                                                          p_name_opr  => lNameOpr,
                                                          p_addr_key  => lAddrKey,
                                                          p_addr_opr  => lAddrOpr,
                                                          p_phone_key => lPhoneKey,
                                                          p_phone_opr => lPhoneOpr,
                                                          p_email_key => lEmailKey,
                                                          p_email_opr => lEmailOpr,
                                                          p_sort_line => lSortLine,
                                                          p_limit     => lLimit,
                                                          p_offset    => lOffset))) loop
        apex_json.open_object;
        apex_json.write('seq_id', c.seq_id);
        apex_json.write('id', c.id);
        apex_json.write('address', c.address, true);
        apex_json.write('phone', c.phone, true);
        apex_json.write('email', c.email, true);
        apex_json.write('name', c.name, true);
        apex_json.close_object;
        lCollectionCount := c.cou; -- constant within loop, just for Pager JSON object
      end loop;
      apex_json.close_array; --  ] -- "data".
      if lCollectionCount = 0 then
        lIsSuccess := false;
        return Errors(8); -- Not found.
      end if;
      -- Pager
      apex_json.open_object('pager');
      apex_json.write('offset', lOffset);
      apex_json.write('total', lCollectionCount);
      apex_json.close_object;
    end if;
    return lError;
  end delivery_points;

  -- Задолженность. Получение коллекции. п. 4.10.1 в ТЗ на разработку АПИ (операция debts)
  -- Ю.К. 24.04.2017
  function debts return rest_api_err is
    lIsSuccess       boolean := true;
    lError           rest_api_err := Errors(1);
    lCurrentUserName varchar2(255);
    lCompanyId       number;
    v_limit          number;
    v_start_with     number;
  begin
    if lIsSuccess then
      lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
      lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName,
                                                            1));
      begin
        v_limit      := apex_json.get_number(p_path    => 'limit',
                                             p_default => 10);
        v_start_with := apex_json.get_number(p_path    => 'offset',
                                             p_default => 1);
      exception
        when others then
          lIsSuccess := false;
          return Errors(5);
      end;
      -- параметры получены.      
      apex_json.open_array('data'); --  "data": [
      for c in (select id,
                       unit,
                       sumDolg,
                       to_char(date_end, 'yyyy-mm-dd hh24:mi:ss') as date_end,
                       status,
                       BaseCurrency
                  from table(mcsf_api.Debts(p_id         => lCompanyId,
                                                p_limit      => v_limit,
                                                p_start_with => v_start_with))) loop
        apex_json.open_object;
        apex_json.write('id', c.id);
        apex_json.write('unit', c.unit);
        apex_json.write('sum', c.sumDolg);
        apex_json.write('date_end', c.date_end);
        apex_json.write('status', c.status);
        apex_json.write('currency', c.BaseCurrency);        
        apex_json.close_object;
      end loop;
      apex_json.close_array; --  ] -- "data".
    end if;
    return lError;
  end debts;

  -- Коллекции контрагентов. Получение коллекции. п. 4.3.1.1 в ТЗ на разработку АПИ (операция shippers)
  -- Ю.К. 

  function shippers return rest_api_err is
    lIsSuccess       boolean := true;
    lError           rest_api_err := Errors(1);
    lCurrentUserName varchar2(255);
    lCompanyId       number;
    v_limit          number;
    v_start_with     number;
    lSortLine        varchar2(2000) := null;
  
    lIdKey                 number;
    lIdOpr                 varchar2(5);
    lClientNameKey         varchar2(2000);
    lClientNameOpr         varchar2(200);
    lOfficialAddressKey    varchar2(2000);
    lOfficialAddressOpr    varchar2(200);
    lOfficialAddressZipKey varchar2(2000);
    lOfficialAddressZipOpr varchar2(200);
    lActualAddressKey      varchar2(2000);
    lActualAddressOpr      varchar2(200);
    lActualAddressZipKey   varchar2(2000);
    lActualAddressZipOpr   varchar2(200);
    lLimitlSortLine        varchar2(2000) := null;
    ord_cou                number := 0;
    i                      number;
    lCount                 number := 0;
    v_sql                  varchar2(20000) := 'select count(distinct c.clnt_id) as id    
  from sbc.clients c, sbc.t_loading_places tlp, sbc.client_requests cr
  where tlp.source_clnt_id = c.clnt_id and 
        ldpl_type = 0 and 
        cr.clrq_id = tlp.clrq_clrq_id and 
        cr.clnt_clnt_id =';
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName,
                                                          1));
    v_sql            := v_sql || lCompanyId || ' ';

    begin
      v_limit      := apex_json.get_number(p_path    => 'limit',
                                           p_default => 10);
      v_start_with := apex_json.get_number(p_path    => 'offset',
                                           p_default => 0);
    
      if apex_json.does_exist(p_path => 'filter') then
        lIdKey                 := apex_json.get_number(p_path    => 'filter.id.value',
                                                       p_default => null);
        lIdOpr                 := apex_json.get_varchar2(p_path    => 'filter.id.type',
                                                         p_default => '=');
        lClientNameKey         := apex_json.get_varchar2(p_path    => 'filter.name.value',
                                                         p_default => '%');
        lClientNameOpr         := apex_json.get_varchar2(p_path    => 'filter.name.type',
                                                         p_default => 'like');
        lOfficialAddressKey    := apex_json.get_varchar2(p_path    => 'filter.official_address.value',
                                                         p_default => '%');
        lOfficialAddressOpr    := apex_json.get_varchar2(p_path    => 'filter.official_address.type',
                                                         p_default => 'like');
        lOfficialAddressZipKey := apex_json.get_varchar2(p_path    => 'filter.official_address_zip.value',
                                                         p_default => '%');
        lOfficialAddressZipOpr := apex_json.get_varchar2(p_path    => 'filter.official_address_zip.type',
                                                         p_default => 'like');
        lActualAddressKey      := apex_json.get_varchar2(p_path    => 'filter.actual_address.value',
                                                         p_default => '%');
        lActualAddressOpr      := apex_json.get_varchar2(p_path    => 'filter.actual_address.type',
                                                         p_default => 'like');
        lActualAddressZipKey   := apex_json.get_varchar2(p_path    => 'filter.actual_address_zip.value',
                                                         p_default => '%');
        lActualAddressZipOpr   := apex_json.get_varchar2(p_path    => 'filter.actual_address_zip.type',
                                                         p_default => 'like');
      else
        lIdKey                 := null;
        lIdOpr                 := '=';
        lClientNameKey         := '%';
        lClientNameOpr         := 'like';
        lOfficialAddressKey    := '%';
        lOfficialAddressOpr    := 'like';
        lOfficialAddressZipKey := '%';
        lOfficialAddressZipOpr := 'like';
        lActualAddressKey      := '%';
        lActualAddressOpr      := 'like';
        lActualAddressZipKey   := '%';
        lActualAddressZipOpr   := 'like';
      end if;
    
      ord_cou := apex_json.get_count(p_path => 'order');
      if ord_cou > 0 then
        for i in 1 .. ord_cou loop
          lSortLine := lSortLine || ', ' ||
                       apex_json.get_varchar2(p_path => 'order[%d]',
                                              p0     => i);
        end loop;
      else
        lSortLine := 'c.clnt_id asc';
      end if;
      lSortLine := ltrim(lSortLine, ', ');
    exception
      when others then
        lIsSuccess := false;
        return Errors(5);
    end;
  
    apex_json.open_array('data');

    for c in (select *
                from table(mcsf_api.getShippers(lCompanyId,
                                                p_clnt_id_key              => lIdKey,
                                                p_client_name_key          => lClientNameKey,
                                                p_official_address_key     => lOfficialAddressKey,
                                                p_official_address_zip_key => lOfficialAddressZipKey,
                                                p_actual_address_key       => lActualAddressKey,
                                                p_actual_address_zip_key   => lActualAddressZipKey,
                                                p_clnt_id_opr              => lIdOpr,
                                                p_client_name_opr          => lClientNameOpr,
                                                p_official_address_opr     => lOfficialAddressOpr,
                                                p_official_address_zip_opr => lOfficialAddressZipOpr,
                                                p_actual_address_opr       => lActualAddressOpr,
                                                p_actual_address_zip_opr   => lActualAddressZipOpr,
                                                p_limit                    => v_limit,
                                                p_start_with               => v_start_with,
                                                p_sort_line                => lSortLine))
              
              ) loop
      apex_json.open_object; --   {    
      apex_json.write('id', c.id); --    "clnt_id":  123, -- NOT NULL;
      apex_json.write('name', c.client_name, true); --    "name": "Horns and hooves ltd",
      apex_json.write('official_address_zip', c.official_address_zip, true);
      apex_json.write('official_address', c.official_address, true);
      apex_json.write('actual_address', c.actual_address, true);
      apex_json.write('actual_address_zip', c.actual_address_zip, true);
    
      apex_json.open_array('persons'); --  "persons": [
      for p in (select * from table(mcsf_api.getPersons(c.id))
                ) loop
        apex_json.open_object; --   {    
        apex_json.write('id', p.id); --    "id":  123, -- NOT NULL;
        apex_json.write('name', p.name, true); --    "name": "Иванов",
        apex_json.write('phone', p.phone, true);
        apex_json.write('email', p.email, true);
        apex_json.write('position', p.position, true);
        apex_json.write('is_decide', p.is_decide, true);
      
        apex_json.close_object; --   }
      end loop;
      apex_json.close_array;
    
      apex_json.close_object; --   }
    end loop;
    apex_json.close_array; --  ]
  
    -- Pager
    apex_json.open_object('pager');
  
    apex_json.write('offset', v_start_with);
  
    if lIdKey is not null then
      v_sql := v_sql || ' and c.clnt_id ' || lIdOpr || ' ' || lIdKey;
    end if;
  
    v_sql := v_sql || ' and nvl(upper(c.client_name), '' '') ' ||
             lClientNameOpr || ' upper(''%' || lClientNameKey || '%'')' ||
             ' and nvl(upper(c.address), '' '') ' || lOfficialAddressOpr ||
             ' upper(''%' || lOfficialAddressKey || '%'')' ||
             ' and nvl(upper(c.zip), '' '') ' || lOfficialAddressZipOpr ||
             ' upper(''%' || lOfficialAddressZipKey || '%'')' ||
             ' and nvl(upper(c.address_fact), '' '') ' || lActualAddressOpr ||
             ' upper(''%' || lActualAddressKey || '%'')' ||
             ' and nvl(upper(c.zip_fact), '' '') ' || lActualAddressZipOpr ||
             ' upper(''%' || lActualAddressZipKey || '%'')';
    if lSortLine is not null then
      v_sql := v_sql || ' order by ' || lSortLine;
    end if;
  
    EXECUTE IMMEDIATE v_sql
      INTO lCount;
  
    apex_json.write('total', lCount);
  
    apex_json.close_object();
    return lError;
  end shippers;

  function consignees return rest_api_err is
    lIsSuccess       boolean := true;
    lError           rest_api_err := Errors(1);
    lCurrentUserName varchar2(255);
    lCompanyId       number;
    v_limit          number;
    v_start_with     number;
    lSortLine        varchar2(2000) := null;
  
    lIdKey                 number;
    lIdOpr                 varchar2(5);
    lClientNameKey         varchar2(2000);
    lClientNameOpr         varchar2(200);
    lOfficialAddressKey    varchar2(2000);
    lOfficialAddressOpr    varchar2(200);
    lOfficialAddressZipKey varchar2(2000);
    lOfficialAddressZipOpr varchar2(200);
    lActualAddressKey      varchar2(2000);
    lActualAddressOpr      varchar2(200);
    lActualAddressZipKey   varchar2(2000);
    lActualAddressZipOpr   varchar2(200);
    lLimitlSortLine        varchar2(2000) := null;
    ord_cou                number := 0;
    i                      number;
    lCount                 number := 0;
    v_sql                  varchar2(20000) := 'select count(distinct c.clnt_id) as id    
  from sbc.clients c, sbc.t_loading_places tlp, sbc.client_requests cr
  where tlp.source_clnt_id = c.clnt_id and 
        ldpl_type = 1 and 
        cr.clrq_id = tlp.clrq_clrq_id and 
        cr.clnt_clnt_id =';
  begin
  
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId       := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName,
                                                          1));
    v_sql            := v_sql || lCompanyId || ' ';
    begin
      v_limit      := apex_json.get_number(p_path    => 'limit',
                                           p_default => 10);
      v_start_with := apex_json.get_number(p_path    => 'offset',
                                           p_default => 0);
    
      if apex_json.does_exist(p_path => 'filter') then
        lIdKey                 := apex_json.get_number(p_path    => 'filter.id.value',
                                                       p_default => null);
        lIdOpr                 := apex_json.get_varchar2(p_path    => 'filter.id.type',
                                                         p_default => '=');
        lClientNameKey         := apex_json.get_varchar2(p_path    => 'filter.name.value',
                                                         p_default => '%');
        lClientNameOpr         := apex_json.get_varchar2(p_path    => 'filter.name.type',
                                                         p_default => 'like');
        lOfficialAddressKey    := apex_json.get_varchar2(p_path    => 'filter.official_address.value',
                                                         p_default => '%');
        lOfficialAddressOpr    := apex_json.get_varchar2(p_path    => 'filter.official_address.type',
                                                         p_default => 'like');
        lOfficialAddressZipKey := apex_json.get_varchar2(p_path    => 'filter.official_address_zip.value',
                                                         p_default => '%');
        lOfficialAddressZipOpr := apex_json.get_varchar2(p_path    => 'filter.official_address_zip.type',
                                                         p_default => 'like');
        lActualAddressKey      := apex_json.get_varchar2(p_path    => 'filter.actual_address.value',
                                                         p_default => '%');
        lActualAddressOpr      := apex_json.get_varchar2(p_path    => 'filter.actual_address.type',
                                                         p_default => 'like');
        lActualAddressZipKey   := apex_json.get_varchar2(p_path    => 'filter.actual_address_zip.value',
                                                         p_default => '%');
        lActualAddressZipOpr   := apex_json.get_varchar2(p_path    => 'filter.actual_address_zip.type',
                                                         p_default => 'like');
      else
        lIdKey                 := null;
        lIdOpr                 := '=';
        lClientNameKey         := '%';
        lClientNameOpr         := 'like';
        lOfficialAddressKey    := '%';
        lOfficialAddressOpr    := 'like';
        lOfficialAddressZipKey := '%';
        lOfficialAddressZipOpr := 'like';
        lActualAddressKey      := '%';
        lActualAddressOpr      := 'like';
        lActualAddressZipKey   := '%';
        lActualAddressZipOpr   := 'like';
      end if;
    
      ord_cou := apex_json.get_count(p_path => 'order');
      if ord_cou > 0 then
        for i in 1 .. ord_cou loop
          lSortLine := lSortLine || ', ' ||
                       apex_json.get_varchar2(p_path => 'order[%d]',
                                              p0     => i);
        end loop;
      else
        lSortLine := 'c.clnt_id asc';
      end if;
      lSortLine := ltrim(lSortLine, ', ');
    exception
      when others then
        lIsSuccess := false;
        return Errors(5);
    end;
  
    apex_json.open_array('data');
  
    for c in (select *
                from table(SBC.mcsf_api.getConsignees(lCompanyId,
                                                      p_clnt_id_key              => lIdKey,
                                                      p_client_name_key          => lClientNameKey,
                                                      p_official_address_key     => lOfficialAddressKey,
                                                      p_official_address_zip_key => lOfficialAddressZipKey,
                                                      p_actual_address_key       => lActualAddressKey,
                                                      p_actual_address_zip_key   => lActualAddressZipKey,
                                                      p_clnt_id_opr              => lIdOpr,
                                                      p_client_name_opr          => lClientNameOpr,
                                                      p_official_address_opr     => lOfficialAddressOpr,
                                                      p_official_address_zip_opr => lOfficialAddressZipOpr,
                                                      p_actual_address_opr       => lActualAddressOpr,
                                                      p_actual_address_zip_opr   => lActualAddressZipOpr,
                                                      p_limit                    => v_limit,
                                                      p_start_with               => v_start_with,
                                                      p_sort_line                => lSortLine))
              
              ) loop
      apex_json.open_object; --   {    
      apex_json.write('id', c.id); --    "clnt_id":  123, -- NOT NULL;
      apex_json.write('name', c.client_name, true); --    "name": "Horns and hooves ltd",
      apex_json.write('official_address_zip', c.official_address_zip, true);
      apex_json.write('official_address', c.official_address, true);
      apex_json.write('actual_address', c.actual_address, true);
      apex_json.write('actual_address_zip', c.actual_address_zip, true);
    
      apex_json.open_array('persons'); --  "persons": [
      for p in (select * from table(SBC.mcsf_api.getPersons(c.id))
                
                ) loop
        apex_json.open_object; --   {    
        apex_json.write('id', p.id); --    "id":  123, -- NOT NULL;
        apex_json.write('name', p.name, true); --    "name": "Иванов",
        apex_json.write('phone', p.phone, true);
        apex_json.write('email', p.email, true);
        apex_json.write('position', p.position, true);
        apex_json.write('is_decide', p.is_decide, true);
      
        apex_json.close_object; --   }
      end loop;
      apex_json.close_array;
    
      apex_json.close_object; --   }
    end loop;
    apex_json.close_array; --  ]
  
    -- Pager
    apex_json.open_object('pager');
  
    apex_json.write('offset', v_start_with);
  
    if lIdKey is not null then
      v_sql := v_sql || ' and c.clnt_id ' || lIdOpr || ' ' || lIdKey;
    end if;
  
    v_sql := v_sql || ' and nvl(upper(c.client_name), '' '') ' ||
             lClientNameOpr || ' upper(''%' || lClientNameKey || '%'')' ||
             ' and nvl(upper(c.address), '' '') ' || lOfficialAddressOpr ||
             ' upper(''%' || lOfficialAddressKey || '%'')' ||
             ' and nvl(upper(c.zip), '' '') ' || lOfficialAddressZipOpr ||
             ' upper(''%' || lOfficialAddressZipKey || '%'')' ||
             ' and nvl(upper(c.address_fact), '' '') ' || lActualAddressOpr ||
             ' upper(''%' || lActualAddressKey || '%'')' ||
             ' and nvl(upper(c.zip_fact), '' '') ' || lActualAddressZipOpr ||
             ' upper(''%' || lActualAddressZipKey || '%'')';
    if lSortLine is not null then
      v_sql := v_sql || ' order by ' || lSortLine;
    end if;
  
    EXECUTE IMMEDIATE v_sql
      INTO lCount;
  
    apex_json.write('total', lCount);
  
    apex_json.close_object();
    return lError;
  end consignees;

  -- Коллекции контрагентов. Получение коллекции. п. 4.3.1.1 в ТЗ на разработку АПИ (операция consignees)
  -- Ю.К.
  
  function Test return rest_api_err is
    lIsSuccess boolean := true;
    lError     rest_api_err := Errors(1);
  
    lOffset number;
    lLimit  number;
  
    lColectionCount number := 0;
  
    lVal varchar2(1000);
    
    lCurrentUserName varchar2(255);
    lCompanyId       number;
  
  begin
    lCurrentUserName := APEX_CUSTOM_AUTH.GET_USERNAME;
    lCompanyId := to_number(APEX_UTIL.GET_ATTRIBUTE(lCurrentUserName, 1));
    
    apex_json.open_object('test');
    apex_json.write('lCompanyId', lCompanyId, true);
    apex_json.close_object;
    return lError;
  
    -- filters
    begin
      lOffset := apex_json.get_number(p_path    => 'offset',
                                      p_default => PkgDefaultOffset);
      lLimit  := apex_json.get_number(p_path    => 'limit',
                                      p_default => PkgDefaultLimit);
    
    exception
      when others then
        lIsSuccess := false;
        lError     := Errors(5);
    end;
    
    lVal := rest_api_helper.PrepareSqlFilter('created_at', 'test');
    
    /*if rest_api_helper.PrepareSortFilter('id') is not null then
       lVal := rest_api_helper.PrepareSortFilter('id', 'o.ord_id');
    end if;*/
  
    htp.print(lVal);
  
    if lIsSuccess then
      apex_json.open_array('data');
    
      for l_c in (select *
                    from (select ROWNUM seq_id, t.*
                            from TABLE(mcsf_api.Test) t) c
                   where c.seq_id > lOffset
                     and c.seq_id <= lOffset + lLimit) loop
      
        apex_json.open_object;
      
        apex_json.write('seq_id', l_c.seq_id, true);
        apex_json.write('id', l_c.id, true);
      
        apex_json.close_object;
      end loop;
    end if;
  
    apex_json.close_array;
  
    -- Pager
    apex_json.open_object('pager');
  
    apex_json.write('offset', lOffset);
  
    select count(t.id) into lColectionCount from TABLE(mcsf_api.Test) t;
  
    apex_json.write('total', lColectionCount);
  
    apex_json.close_object();
  
    return lError;
  end;

  -- ================================================
  /*
   Журнал протоколирования ошибок и тестирования
  */
  procedure ins_syslog(mess in varchar2, logdate in date) is
  begin
    insert into sys_logs (msg, log_date) values (mess, logdate);
    commit;
  end;
  -- ======================================================
BEGIN

  Errors := ErrorsArrType();

  Errors.EXTEND(10);

  Errors(1) := rest_api_err('success', 'success', 1);

  Errors(2) := rest_api_err('unauthorized', 'Unauthorized', 0);

  Errors(3) := rest_api_err('service_internal_error',
                            'Service internal error',
                            0);

  Errors(4) := rest_api_err('bad_operation', 'Bad operation', 0);

  Errors(5) := rest_api_err('bad_filter', 'Bad filter', 0);

  Errors(6) := rest_api_err('bad_order', 'Bad order', 0);

  Errors(7) := rest_api_err('bad_file', 'Bad file', 0);

  Errors(8) := rest_api_err('not_found', 'Not found', 0);

  Errors(9) := rest_api_err('bad_data', 'Bad data', 0);

-- YK, 07.11.2017:  
  Errors(10) := rest_api_err('check_point', 'Check Point', 0);  

END REST_API;
/
