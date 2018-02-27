CREATE OR REPLACE PACKAGE SBC_MESSAGE AS
/******************************************************************************
   NAME:       SBC_MESSAGE
   PURPOSE: Пакет для обработки и отпавки сообщений

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14.05.2008  Dim_ok     1. Создан пакет.
   1.1        02.06.2008  Dim_ok     1. Добавлена функция возврата APPID. /SET_ApplId/
   1.2        09.06.2008  Dim_ok     1. Добавленна доп облаботка (Если у сообщения не проставлен клиет то проставляем в процедуре SendMessageToMail)
   1.3        11.09.2008  Dim_ok     1. В процедуру HandleError сделана автономной транзакцией
                          Dim_ok     2. В процедуру SBC_SendMail добавлен параметр P_MES_EMAIL_AUTH авторизации
                          Dim_ok     3. Усттановленна проверка на повторное сообщение
   1.4        23.12.2013  DP         Добавлена процедура Del_old_mails_f_mess2cust. Доработана ADD_Message процедура в связи с обработкой информации из MESSAGE_SUBSCRIPTIONS таблицы
   1.4.2      17.02.2014  AS         Увеличены str, str1, str2, str3 и ss в READ_BODY_MSG_F.
   1.4.2      20.02.2014  DP         Изменена логика по выборке 'порта прибытия'.
   1.4.2      27.02.2014  DP         Добавлено P_orst_tmms и именена логика выборки MESSAGES_TEXT, заголовок сообщения.
   1.4.4      20.03.2014  DP         Изменена логика формирования Русского языка, V_fl_name.
   1.4.5      31.03.2014  DP         Добавлена emails2line функция и много e-mails отправка по одному сообщению.
   1.4.6      16.04.2014  DP         Добавлена <груз по заявке> переменная.
   1.4.7      24.04.2014  DP         Убрано время из <дата убытия к клиенту> переменной.
   1.4.8      29.04.2014  DP         Изменена логика по выборке 'контейнер' переменной.
   1.4.9      20.05.2014  DP         Изменена логика рассылки "Дата выпуска ГТД " сообщения.
   2.0.1      04.05.2016  А.В. Старшинин Удалена вставка отладочных сообщений в таблицу SYS_LOGS

******************************************************************************/
-- Код приложения

 ApplId NUMBER := 21;

-- Параметры для отправки почты
 MES_EMAIL_FROM varchar2(255);   -- Имя пользователя, от имени которого отправляется почта
 MES_EMAIL_SERVER varchar2(255); -- Имя почтового сервера для отправки сообщений
 MES_EMAIL_PASSW varchar2(255);  -- Пароль пользователя, от которого отправляется почта
 MES_EMAIL_PORT varchar2(50);    -- Порт для почтового сервера
 MES_EMAIL_NAME varchar2(50);    -- Имя владельца (пользователя) почтового ящика
 MES_EMAIL_AUTH boolean ;        -- Использовать авторизацию на сервере
 MES_WALLET_PATH varchar2(2000); -- Путь к кошельку
 MES_WALLET_PASS varchar2(2000); -- Пароль к кошельку


-- Настройка параметров почты
PROCEDURE SET_PARAM_EMAIL;

-- Функция возврата ApplId
FUNCTION SET_ApplId RETURN NUMBER;

-- Функция отправки сообщения -- Результат отправки (1-ошибка, 0-все нормально)
FUNCTION SBC_SendMail(p_rcvr_name  in varchar2 default 'Ваше лицо', -- Имя получателя
                      p_rcvr_email in varchar2 , -- Почтовый ящик получателя
                      p_subject    in varchar2 ,  -- Тема письма
                      p_text       in varchar2 , -- текст письма
                      P_MES_EMAIL_FROM   in varchar2 default null,  -- Имя пользователя, от имени которого отправляется почта
			            		P_MES_EMAIL_NAME   in varchar2 default null,  -- Имя владельца (пользователя) почтового ящика
                      P_MES_EMAIL_SERVER in varchar2 default null,  -- Имя почтового сервера для отправки сообщений
                      P_MES_EMAIL_PASSW  in varchar2 default null,  -- Пароль пользователя, от которого отправляется почта
            					P_MES_EMAIL_PORT varchar2 default null,       -- Порт для почтового сервера
  					          P_MES_EMAIL_AUTH boolean default null,        -- Использовать авторизацию на сервере
                      p_attachment_name  in varchar2 default null,  -- Наименование файла
                      p_attachment_mimetype varchar2 default null,  -- Тип кодировки файла
						          P_BLOB Blob default null,                     -- Сам файл
                      p_rcvr_email_copy varchar2 default null       -- Список адресатор в копии письма
                     ) RETURN NUMBER;
  -- Процедура генерации прикладной ошибки
PROCEDURE RaiseError(
					   TEXT varchar2 -- Текст ошибки
                      ,CODE number default -20000  -- Код ошибки
                       );

  -- Процедура обработки исключений и записи в лог
PROCEDURE HandleError(
    pErrCode INTEGER,                                 -- Код ошибки Oracle
    pErrMsg VARCHAR2,                                 -- Текст сообщения об ошибке Oracle
    pObjectName VARCHAR2                              -- Имя объекта, в котором возникла ошибка
  );                                                  -- Код ошибки из таблицы ErrorMsg

--  Добавление/Редактирование нового шаблона
PROCEDURE IE_TEMPLATES_MESSAGES(P_DEF TEMPLATES_MESSAGES.DEF%TYPE  -- Наименование
                                    ,P_APPL_APPL_ID TEMPLATES_MESSAGES.APPL_APPL_ID%TYPE  -- Приложение
                                    ,P_MESSAGES_TEXT TEMPLATES_MESSAGES.MESSAGES_TEXT%TYPE  -- Текст шаблона
									,P_STORE_DAYS TEMPLATES_MESSAGES.STORE_DAYS%TYPE default null  -- Количество дней
									,P_DEL_DATE TEMPLATES_MESSAGES.DEL_DATE%TYPE default null -- Дата удаления
									,P_DEL_USER TEMPLATES_MESSAGES.DEL_USER%TYPE default null -- Кто удалил
                                    ,P_TM_ID TEMPLATES_MESSAGES.TM_ID%TYPE DEFAULT NULL  -- Код шаблона
                                     );

-- Список переменных
FUNCTION GET_VALUES_MESSAGES(P_APPL_APPL_ID IN NUMBER default null) RETURN TBL_VALUES_MESSAGES;


-- Заменяет переменные в тексте шаблона на значения и возвращяет готовый текст
FUNCTION SET_VALUES_MESSAGES(P_ORD_ID   ORDERS.ORD_ID%TYPE,  -- Код заказа
                             P_MESSAGE_TEXT  MESSAGES2CUSTOMERS.MESSAGE_TEXT%TYPE -- Текст шаблона
							  ) RETURN VARCHAR2;

-- Добавить сообщение
PROCEDURE ADD_Message(P_ORST_ID ORDER_STATUSES.ORST_ID%type  -- Код статуса
                      ,P_ORD_ORD_ID ORDERS.ORD_ID%type  -- Код заказа
                      ,P_orst_tmms orders.stop_order%type      default 0 -- Если P_orst_tmms = 0 то передали ORST_ID, а если P_orst_tmms = 1 то передали TM_ID
                      );

-- Обработка сообщения
PROCEDURE EXE_Message(P_MSCM_ID MESSAGES2CUSTOMERS.MSCM_ID%type,  -- Код сообщения
                      P_message_text OUT MESSAGES2CUSTOMERS.message_text%type,  -- Текс сообщения
					            P_send_to OUT MESSAGES2CUSTOMERS.send_to%type,  -- Адрес отправителя
				           	  P_HOLD_HOLD_ID OUT MESSAGES2CUSTOMERS.HOLD_HOLD_ID%type,  -- Холдинг
			          		  P_CLNT_CLNT_ID OUT MESSAGES2CUSTOMERS.CLNT_CLNT_ID%type,  -- Клиент
                      P_orst_tmms  MESSAGES2CUSTOMERS.orst_tmms%type, -- Если P_orst_tmms = 0 то передали ORST_ID, а если P_orst_tmms = 1 то передали TM_ID
                      P_tm_ms_def OUT templates_messages.def%type); -- заголовок сообщения


-- Удаляет лишние тэги
FUNCTION READ_BODY_MSG_F(P_MESSAGE_TEXT  MESSAGES2CUSTOMERS.MESSAGE_TEXT%TYPE) RETURN VARCHAR2;

-- Отправка сообщений, которые не отправленны
PROCEDURE SendMessageToMail;

--*************************************************************************************************

--*************************************************************************************************
-- Deleted the messages from messages2customers table which older then message_date+store_days
--*************************************************************************************************
procedure Del_old_mails_f_mess2cust;

--*************************************************************************************************
-- Перевод значений представленных в виде столбца в линейные
--*************************************************************************************************

function emails2line(P_ORD_ID IN T_ORDERS.ORD_ID%TYPE) RETURN VARCHAR2;
END SBC_MESSAGE;
/
CREATE OR REPLACE PACKAGE BODY SBC_MESSAGE AS


-- Функция возврата ApplId
FUNCTION SET_ApplId RETURN NUMBER IS
Begin
  RETURN ApplId;
end;

-- Настройка параметров почты
PROCEDURE SET_PARAM_EMAIL IS
CURVAL VARCHAR2(255);
  FUNCTION SET_APP_PARAM(Name_Param VARCHAR2) RETURN varchar2 IS
  Value_Param varchar2(255);
  begin
     begin
        SELECT Trim(VALUE_STRING)
          INTO Value_Param
          FROM APP_PARAMETERS
         WHERE CODE = UPPER(Trim(Name_Param)) and appl_appl_id=ApplId;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
	          Value_Param :='-';
     end;
	   if Value_Param='-' then
        HandleError(-20000, 'Не найден настроечный параметр:"'||UPPER(Trim(Name_Param))||'"', 'SET_PARAM_EMAIL');
        --	 ins_sys_logs(ApplId=>ApplId,Message=>'Не найден настроечный параметр:"'||UPPER(Trim(Name_Param))||'"');
	   end if;
     RETURN Value_Param;
  end;

begin
  -- Имя пользователя, от имени которого отправляется почта
  MES_EMAIL_FROM := SET_APP_PARAM('MES_EMAIL_FROM');
  -- Имя почтового сервера для отправки сообщений
  MES_EMAIL_SERVER := SET_APP_PARAM('MES_EMAIL_SERVER');
  -- Пароль пользователя, от которого отправляется почта
  MES_EMAIL_PASSW := SET_APP_PARAM('MES_EMAIL_PASSW');
  -- Порт для почтового сервера
  MES_EMAIL_PORT := SET_APP_PARAM('MES_EMAIL_PORT');
  -- Имя владельца (пользователя) почтового ящика
  MES_EMAIL_NAME := SET_APP_PARAM('MES_EMAIL_NAME');
  -- Использовать авторизацию на сервере
  if SET_APP_PARAM('MES_EMAIL_AUTH')='1' then
     MES_EMAIL_AUTH := true;
  else
     MES_EMAIL_AUTH := False;
  end if;
  -- Путь к кошельку
  MES_WALLET_PATH := SET_APP_PARAM('MES_WALLET_PATH');
  -- Адрес кошелька
  MES_WALLET_PASS := SET_APP_PARAM('MES_WALLET_PASS');
end;

-- Процедура отправки сообщения
/*  Пример
              res:=SBC_SendMail('Клиент',
                           loop_1.send_to,
                           'Обработка Событий',
                          '<font size="14px" >'||'<p>'||concat_text||'</p></font>');
Пример 2 счерез почтовый сервер MAIL
declare
  nn number;
begin
              nn:=SBC_MESSAGE.SBC_SendMail(p_rcvr_name=>'Клиент',
                          p_rcvr_email=>'Dim_ok@sbconsulting.ru', -- Почтовый ящик получателя
                          p_subject=>'Привет11', -- Тема письма
                          p_text=>'<font size="14px" >'||'<p>'||'Такие вот дела'||'</p></font>', -- текст письма
                          P_MES_EMAIL_FROM=>'test@mail.ru',   -- Имя пользователя, от имени которого отправляется почта
						  P_MES_EMAIL_NAME=>'test', -- Имя владельца (пользователя) почтового ящика
                          P_MES_EMAIL_SERVER=>'smtp.mail.ru', -- Имя почтового сервера для отправки сообщений
                          P_MES_EMAIL_PASSW=>'test',  -- Пароль пользователя, от которого отправляется почта
						  P_MES_EMAIL_PORT=>2525,  -- Порт для почтового сервера
  						  P_MES_EMAIL_AUTH=>true  -- Использовать авторизацию на сервере
						  );
  RAISE_APPLICATION_ERROR(-20000, 'Результат выполнения='||To_Char(nn));
end;

*/
FUNCTION SBC_SendMail(p_rcvr_name  in varchar2 default 'Ваше лицо', -- Имя получателя
                      p_rcvr_email in varchar2 , -- Почтовый ящик получателя
                      p_subject    in varchar2 ,  -- Тема письма
                      p_text       in varchar2 , -- текст письма
                      P_MES_EMAIL_FROM   in varchar2 default null,  -- Имя пользователя, от имени которого отправляется почта
			            		P_MES_EMAIL_NAME   in varchar2 default null,  -- Имя владельца (пользователя) почтового ящика
                      P_MES_EMAIL_SERVER in varchar2 default null,  -- Имя почтового сервера для отправки сообщений
                      P_MES_EMAIL_PASSW  in varchar2 default null,  -- Пароль пользователя, от которого отправляется почта
            					P_MES_EMAIL_PORT varchar2 default null,       -- Порт для почтового сервера
  					          P_MES_EMAIL_AUTH boolean default null,        -- Использовать авторизацию на сервере
                      p_attachment_name  in varchar2 default null,  -- Наименование файла
                      p_attachment_mimetype varchar2 default null,  -- Тип кодировки файла
						          P_BLOB Blob default null,                     -- Сам файл
                      p_rcvr_email_copy varchar2 default null       -- Список адресатор в копии письма
                     ) RETURN NUMBER IS
 V_RES              number;
begin
 BEGIN
    V_RES:=1;
-- Установка переменных из базы ************************************************************************************
    SET_PARAM_EMAIL;
    if (trim(P_MES_EMAIL_FROM) IS NOT NULL)   then MES_EMAIL_FROM   := P_MES_EMAIL_FROM; end if;
    if (trim(P_MES_EMAIL_SERVER) IS NOT NULL) then MES_EMAIL_SERVER := P_MES_EMAIL_SERVER; end if;
    if (trim(P_MES_EMAIL_PASSW) IS NOT NULL)  then MES_EMAIL_PASSW  := P_MES_EMAIL_PASSW; end if;
    if (trim(P_MES_EMAIL_PORT) IS NOT NULL)   then MES_EMAIL_PORT   := P_MES_EMAIL_PORT; end if;
    if (trim(P_MES_EMAIL_NAME) IS NOT NULL)   then MES_EMAIL_NAME   := P_MES_EMAIL_NAME; end if;
    if (P_MES_EMAIL_AUTH IS NOT NULL)         then MES_EMAIL_AUTH   := P_MES_EMAIL_AUTH; end if;
--*******************************************************************************************************************
    IF trim(p_attachment_name) is not null then
       SBC_MAIL.ADD_ATTACHMENT(P_BLOB,p_attachment_name,'text/html');
    end if;

    V_RES := sbc_mail.send_mail(p_rcvr_email => p_rcvr_email,
                                p_rcvr_email_copy => p_rcvr_email_copy,
                                p_subject => p_subject,
                                p_text => p_text,
                                p_appl_id => ApplId ,
                                p_sys_log_marker => 'Отправка сообщений клиентам',
                                p_mes_email_from => MES_EMAIL_FROM,
                                p_mes_email_name => MES_EMAIL_NAME,
                                p_mes_email_server => MES_EMAIL_SERVER,
                                p_mes_email_passw => MES_EMAIL_PASSW,
                                p_mes_email_port => MES_EMAIL_PORT,
                                p_mes_email_auth => MES_EMAIL_AUTH,
                                p_mes_wallet_path => MES_WALLET_PATH,
                                p_mes_wallet_pass => MES_WALLET_PASS);
    Return V_RES;
 end;
end;

-- Процедура генерации прикладной ошибки
PROCEDURE RaiseError(TEXT varchar2,              -- Текст ошибки
                     CODE number default -20000  -- Код ошибки
                    ) IS
BEGIN
    RAISE_APPLICATION_ERROR(-20000, TEXT);
END;

  -- Процедура обработки исключений
PROCEDURE HandleError(pErrCode INTEGER,    -- Код ошибки Oracle
                      pErrMsg VARCHAR2,    -- Текст сообщения об ошибке Oracle
                      pObjectName VARCHAR2 -- Имя объекта, в котором возникла ошибка
                     ) IS
pragma autonomous_transaction;
BEGIN
   IF pErrCode = (-20001) THEN
      ins_sys_logs(ApplId=>ApplId,Message=>pObjectName||', '||pErrMsg, IsCommit=>True);
   elsif pErrCode NOT IN(-2292) THEN
     ins_sys_logs(ApplId=>ApplId,Message=>pObjectName||', '||pErrMsg, IsCommit=>False);
   END IF;
   CASE pErrCode
      -- Стандартные исключения Oracle и доморощенные в SBConsulting
	    WHEN -6530 then RaiseError('Попытка доступа к неинициализированной переменной (ACCESS_INTO_NULL)',pErrCode);
      WHEN -6592 then RaiseError('Не найдено значение в операторе CASE (CASE_NOT_FOUND)',pErrCode);
      WHEN -6511 then RaiseError('Попытка открыть открытый курсор (CURSOR_ALREADY_OPEN)',pErrCode);
      WHEN -1    then RaiseError('Запись уже существует (DUP_VAL_ON_INDEX)',pErrCode);
      WHEN -1001 then RaiseError('Ошибочная операция с курсором (INVALID_CURSOR)',pErrCode);
      WHEN -1722 then RaiseError('Ошибка преобразования строки в число (INVALID_NUMBER)',pErrCode);
      WHEN 100   then RaiseError('Не найдены записи, удовлетворяющие условию (NO_DATA_FOUND)',pErrCode);
      WHEN -6501 then RaiseError('Внутренняя ошибка PL/SQL (PROGRAM_ERROR)',pErrCode);
      WHEN -6504 then RaiseError('Не совпадение типов (ROWTYPE_MISMATCH)',pErrCode);
      WHEN -6500 then RaiseError('Ошибка памяти (STORAGE_ERROR)',pErrCode);
      WHEN -1410 then RaiseError('Неправильный системный номер записи (SYS_INVALID_ROWID)',pErrCode);
      WHEN -51   then RaiseError('Время ожидания ресурса истекло (TIMEOUT_ON_RESOURCE)',pErrCode);
      WHEN -1422 then RaiseError('Слишком большое количество записей (TOO_MANY_ROWS)',pErrCode);
      WHEN -6502 then RaiseError('Ошибка присвоения значения переменной (VALUE_ERROR)',pErrCode);
      WHEN -1476 then RaiseError('Деление на ноль (ZERO_DIVIDE)',pErrCode);
      WHEN -2292 then RaiseError('Существуют порожденные записи (INTEGRITY_CONSTRAINT)',pErrCode);
   ELSE
      RaiseError(pObjectName||', '||pErrMsg,pErrCode);
   END CASE;
   commit;
END HandleError;

--  Добавление/Редактирование нового шаблона
PROCEDURE IE_TEMPLATES_MESSAGES(P_DEF TEMPLATES_MESSAGES.DEF%TYPE,                             -- Наименование
                                P_APPL_APPL_ID TEMPLATES_MESSAGES.APPL_APPL_ID%TYPE,           -- Приложение
                                P_MESSAGES_TEXT TEMPLATES_MESSAGES.MESSAGES_TEXT%TYPE,         -- Текст шаблона
									              P_STORE_DAYS TEMPLATES_MESSAGES.STORE_DAYS%TYPE default null,  -- Количество дней
									              P_DEL_DATE TEMPLATES_MESSAGES.DEL_DATE%TYPE default null,      -- Дата удаления
									              P_DEL_USER TEMPLATES_MESSAGES.DEL_USER%TYPE default null,      -- Кто удалил
                                P_TM_ID TEMPLATES_MESSAGES.TM_ID%TYPE DEFAULT NULL             -- Код шаблона
                               ) IS
V_TM_ID number;
EDIT boolean;
V_RESULT VARCHAR2(2000);
V_MESSAGES_TEXT VARCHAR2(2000);
Begin
   IF (trim(P_MESSAGES_TEXT) IS NULL) THEN
      RaiseError('Не ввели текст шаблона!!!');
   END IF;
   IF (trim(P_TM_ID) IS NULL) THEN
	    EDIT := False;
	    select TM_SEQ.nextval into V_TM_ID from dual;
	 else
      EDIT := True;
      V_TM_ID := P_TM_ID;
   END IF;
   -- Проверка на текст сообщения
   V_MESSAGES_TEXT := P_MESSAGES_TEXT;
   -- Удаляем переменные
   For DAN in (Select DEF
                 from table(cast(SBC_MESSAGE.GET_VALUES_MESSAGES as tbl_VALUES_MESSAGES))
              )loop
      V_MESSAGES_TEXT := REPLACE(UPPER(V_MESSAGES_TEXT),UPPER(DAN.DEF),'');
   end loop;
   -- проверяем на оставшиеся переменые
   if INSTR(V_MESSAGES_TEXT,'<') <> 0 Then
      RaiseError('Неверный текст шаблона, переменная ('||SUBSTR(V_MESSAGES_TEXT,INSTR(V_MESSAGES_TEXT,'<'),INSTR(V_MESSAGES_TEXT,'>')-INSTR(V_MESSAGES_TEXT,'<')+1)||')не найденна в списке переменных.');
   end if;

   Begin
	     if EDIT then -- Редактирование
	        UPDATE TEMPLATES_MESSAGES
	           SET TM_ID = P_TM_ID,
	               DEF = P_DEF,
		             APPL_APPL_ID = P_APPL_APPL_ID,
                 MESSAGES_TEXT = P_MESSAGES_TEXT,
                 STORE_DAYS = P_STORE_DAYS,
                 DEL_DATE = P_DEL_DATE,
                 DEL_USER=P_DEL_USER
	         WHERE TM_ID = V_TM_ID;
	     Else -- Внесение нового
          INSERT into TEMPLATES_MESSAGES(TM_ID, DEF, APPL_APPL_ID, MESSAGES_TEXT, STORE_DAYS, DEL_DATE, DEL_USER)
          VALUES(V_TM_ID, P_DEF, P_APPL_APPL_ID, P_MESSAGES_TEXT, P_STORE_DAYS, P_DEL_DATE, P_DEL_USER);
	     end if;
   EXCEPTION
      WHEN OTHERS THEN
         HandleError(SQLCODE, SQLERRM, 'IE_TEMPLATES_MESSAGES');
   end;
end;

-- Список переменных
FUNCTION GET_VALUES_MESSAGES(P_APPL_APPL_ID IN NUMBER default null)
  RETURN TBL_VALUES_MESSAGES IS
P_VALUES_MESSAGES TBL_VALUES_MESSAGES := TBL_VALUES_MESSAGES();
i number;
begin
    -- Заносим переменные
    i:=0;
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<номер заказа>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<дата заказа>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<дата выпуска ГТД>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<дата отгрузки>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<дата выгрузки>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<контейнер>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<грузоотправитель>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<город отправки>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<дата погрузки>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<судно>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<порт прибытия>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<город прибытия>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<ожидаемая дата>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<дата прибытия>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<дата убытия>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<номер авто>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<фамилия>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<телефон>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<внутренний номер заказа>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<планируемая дата прибытия>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<склад>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<номер авто к клиенту>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<фамилия к клиенту>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<дата убытия к клиенту>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<телефон к клиенту>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<дата подачи>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<груз по заявке>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<br>',null);

-- Тэги
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<b>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('</b>',null);
    i:=i+1; P_VALUES_MESSAGES.extend;
    P_VALUES_MESSAGES(i):= t_VALUES_MESSAGES('<not>',null);

	RETURN (P_VALUES_MESSAGES);
end;

-- Заменяет переменные в тексте шаблона на значения и возвращяет готовый текст
FUNCTION SET_VALUES_MESSAGES(P_ORD_ID   ORDERS.ORD_ID%TYPE,                        -- Код заказа
                             P_MESSAGE_TEXT  MESSAGES2CUSTOMERS.MESSAGE_TEXT%TYPE  -- Текст шаблона
							  ) RETURN VARCHAR2 IS
V_MSG_INFO     APP_PARAMETERS.VALUE_STRING%TYPE;
V_ORD_NUMBER   ORDERS.ORD_NUMBER%TYPE;
V_ORD_DATE     ORDERS.ORD_DATE%TYPE;
V_DATE_IN      ORDER_WAYS.DATE_IN%TYPE;
V_DATE_OUT     ORDER_WAYS.DATE_OUT%TYPE;
V_DATE_OUT_GTD GTDS.DATE_OUT%TYPE;
V_VOCH_DATE    VOUCHERS.VOCH_DATE%TYPE;
V_CITY_DEF     CITIES.DEF%TYPE;
V_CITY_DEF_POD CITIES.DEF%TYPE;
V_SHORT_NAME   CLIENTS.SHORT_NAME%TYPE;
V_CONT_NUMBER  CONTEINERS.CONT_NUMBER%TYPE; -- VARCHAR2(50);
V_ETA_DATE     TRANSPORT_TIME_TABLE.ETA_DATE%TYPE;
V_PORT_OUT     PORTS.DEF%TYPE; --VARCHAR2(50);
V_PORT_OUT_df  cmrs.PORT_OUT%TYPE;
V_PORT_DEF     PORTS.DEF%TYPE; --VARCHAR2(50);
V_CAR_NUMBER   CARS.STATE_NUMBER%TYPE;
V_DRIVER_NAME  CMRS.DRIVER_NAME%TYPE;
V_DRIVER_PHONE CMRS.DRIVER_PHONE%TYPE;
V_ARRIVAL_DATE TRANSPORT_TIME_TABLE.ARRIVAL_DATE%TYPE;
V_SHIP_DEF     SHIPS.DEF%TYPE;
V_ORD_NAMER    ORDERS.INTERNAL_NUMBER%TYPE;
V_DATE_PLAN    order_ways.DATE_PLAN%TYPE;
V_SKLAD        stores.def%TYPE;  -- склад
V_gruz_po_zayavke FREIGHTS.def%TYPE; -- Наименование груза
V_CAR_NUMBER_C   CARS.STATE_NUMBER%TYPE;  --<номер авто к клиенту>
V_DRIVER_NAME_C  CMRS.DRIVER_NAME%TYPE; -- <фамилия к клиенту>
V_DRIVER_PHONE_C CMRS.DRIVER_PHONE%TYPE; --<телефон к клиенту>
V_DATE_C         CMRS.PORT_OUT%TYPE; --<дата убытия к клиенту>
V_DATE_POD date;   -- <дата подачи>
i number;
SKLAD varchar2(200);
BEGIN
   V_MSG_INFO:=P_MESSAGE_TEXT;
   IF (INSTR(V_MSG_INFO, '<дата заказа>') > 0) OR (INSTR(V_MSG_INFO, '<номер заказа>') > 0) THEN
      BEGIN
        SELECT O.ORD_DATE, O.ORD_NUMBER
          INTO V_ORD_DATE, V_ORD_NUMBER
          FROM ORDERS O
         WHERE O.ORD_ID = P_ORD_ID;
      EXCEPTION
        WHEN others THEN
          V_ORD_DATE:=null;
          V_ORD_NUMBER:=null;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<дата выпуска ГТД>') > 0)  THEN
       BEGIN
          select date_out
            INTO V_DATE_OUT_GTD
            from GTDS
           where GTD_ID in (select GTD_GTD_ID from gtd_payments where ORD_ORD_ID=P_ORD_ID);
       EXCEPTION
         WHEN others THEN
           V_DATE_OUT_GTD:=null;
       END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<дата отгрузки>') > 0) THEN
      BEGIN
         SELECT OW.DATE_IN
           INTO V_DATE_IN
           FROM ORDER_WAYS OW
          WHERE OW.ORD_ORD_ID = P_ORD_ID AND
                OW.ORWS_TYPE = 1 AND
                OW.DATE_IN IS NOT NULL AND
                OW.DEL_DATE is null;
      EXCEPTION
         WHEN OTHERS THEN
           V_DATE_IN:=null;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<дата выгрузки>') > 0) THEN
      BEGIN
         select voch_date
           into V_VOCH_DATE
           from VOUCHERS
          where VOCH_ID in (select VOCH_VOCH_ID from voch_details where ord_ord_id=P_ORD_ID);
      EXCEPTION
        WHEN OTHERS THEN
          V_VOCH_DATE:=null;
      END;
    END IF;
--
    IF (INSTR(V_MSG_INFO, '<склад>') > 0) THEN
      BEGIN
        i:=0;
        SKLAD:='';
        FOR DAN in (select s.def
                      from cmrs cm, ports s, ORDER_WAYS OW3
                     where OW3.ORD_ORD_ID = P_ORD_ID AND
                           OW3.ORWS_TYPE  = 3 AND
                           OW3.DEL_DATE is null and
                           OW3.orws_id = cm.orws_orws_id and
                           cm.port_port_in_id = s.port_id(+) and
                           cm.del_date is Null
               		   order by cm.cmr_id desc) loop
            I:=I+1;
            SKLAD:=DAN.DEF;
            if I>=2 then
               exit;
            end if;
        end loop;
	      V_SKLAD:=SKLAD;
      EXCEPTION
        WHEN OTHERS THEN
           V_SKLAD:=NULL;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<номер авто к клиенту>') > 0) OR
       (INSTR(V_MSG_INFO, '<фамилия к клиенту>') > 0) OR
       (INSTR(V_MSG_INFO, '<дата убытия к клиенту>') > 0) OR
       (INSTR(V_MSG_INFO, '<телефон к клиенту>') > 0) THEN
       BEGIN
          select cr.state_number, c.DRIVER_NAME, c.DRIVER_PHONE, NVL(c.PORT_OUT, C.DATE_OUT)
            INTO V_CAR_NUMBER_C, V_DRIVER_NAME_C, V_DRIVER_PHONE_C, V_DATE_C
            from CMRS c, cars cr
           where c.cmr_id =(select distinct first_value(od.cmr_id) over (order by od.cmr_id desc)
                              from cmrs od, order_ways ow3
                             where ow3.ord_ord_id = P_ORD_ID AND
                                   ow3.orws_type  = 3 AND
                                   ow3.del_date is null AND
                                   ow3.orws_id = od.orws_orws_id) and
                 c.car_car_id = cr.car_id(+) and
                 c.del_date is Null;
       EXCEPTION
         WHEN OTHERS THEN
            V_CAR_NUMBER_C:=NULL; V_DRIVER_NAME_C:=NULL; V_DRIVER_PHONE_C:=NULL; V_DATE_C:=NULL;
       END;
    END IF;

--*********
    IF (INSTR(V_MSG_INFO, '<контейнер>') > 0) THEN
      BEGIN
        SELECT CN.CONT_INDEX || CN.CONT_NUMBER
          INTO V_CONT_NUMBER
          FROM ORDERS O, CONTEINERS CN
         WHERE O.ORD_ID = P_ORD_ID
           AND CN.CONT_ID(+) = O.CONT_CONT_ID;
      EXCEPTION
        WHEN OTHERS THEN
          V_CONT_NUMBER:=NULL;
      END;
      if  nvl(V_CONT_NUMBER,'0')='0' then
         BEGIN
            select CONT_INDEX || CONT_NUMBER
              INTO V_CONT_NUMBER
              from ORDER_WAYS
             where ORD_ORD_ID = P_ORD_ID and orws_type=1 ;
         EXCEPTION
            WHEN OTHERS THEN
                V_CONT_NUMBER:=NULL;
         END;
      end if;
    END IF;

    IF (INSTR(V_MSG_INFO, '<грузоотправитель>') > 0) THEN
      BEGIN
        SELECT CL.SHORT_NAME
          INTO V_SHORT_NAME
          FROM LOADING_PLACES LP, CLIENTS CL
         WHERE LP.ORD_ORD_ID = P_ORD_ID
           AND LP.SOURCE_TYPE = 0 -- основное место погрузки
           AND LP.SOURCE_CLNT_ID = CL.CLNT_ID(+)
		   -- проверка на удаление погрузки
		   and lp.DEL_DATE is null;
      EXCEPTION
        WHEN OTHERS THEN
          V_SHORT_NAME:=NULL;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<город отправки>') > 0) THEN
      BEGIN
        SELECT C.DEF
          INTO V_CITY_DEF
          FROM LOADING_PLACES LP, CITIES C
         WHERE LP.ORD_ORD_ID = P_ORD_ID
           AND LP.SOURCE_TYPE = 0
           AND LP.CITY_CITY_ID = C.CITY_ID
		   -- проверка на удаление погрузки
		   and lp.DEL_DATE is null;
      EXCEPTION
        WHEN OTHERS THEN
          V_CITY_DEF:=null;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<дата погрузки>') > 0) THEN
      BEGIN
        SELECT OW.DATE_OUT
          INTO V_DATE_OUT
          FROM ORDER_WAYS OW
         WHERE OW.ORD_ORD_ID = P_ORD_ID
           AND OW.ORWS_TYPE = 1
           AND OW.DATE_OUT IS NOT NULL;
      EXCEPTION
        WHEN OTHERS THEN
          V_DATE_OUT:=NULL;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<судно>') > 0) THEN
      BEGIN
        SELECT S.DEF
          INTO V_SHIP_DEF
          FROM ORDER_WAYS  OW,
               ORDERS      O,
               KNOR_ORD    KO,
               KNSM_ORDERS KR,
               KONOSAMENTS K,
               SHIPS       S
         WHERE OW.ORWS_TYPE = 1
           AND O.ORD_ID = OW.ORD_ORD_ID
           AND O.ORD_ID = KO.ORD_ORD_ID(+)
           AND KO.KNOR_KNOR_ID = KR.KNOR_ID(+)
           AND KR.KNSM_KNSM_ID = K.KNSM_ID(+)
           AND K.TRSP_TRSP_ID = S.TRSP_ID(+)
           AND KNSM_TYPE = 2 -- Океанский
           AND O.ORD_ID = P_ORD_ID
		   and Trim(S.DEF)<>'';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
	 	  	   select s_f.def
		         INTO V_SHIP_DEF
			       From orders o, KNOR_ORD KO, KNSM_ORDERS KR, KONOSAMENTS K,
					        SHIPS S, transport_time_table tt, ships s_f, ORDER_WAYS  OW
				    where o.ORD_ID=P_ORD_ID and
                  O.ORD_ID = KO.ORD_ORD_ID(+) AND
                  KO.KNOR_KNOR_ID = KR.KNOR_ID(+) AND
                  KR.KNSM_KNSM_ID = K.KNSM_ID(+) AND
          				--and k.IS_CUSTOM=1  -- Есть отметка таможни
				          K.TRSP_TRSP_ID = S.TRSP_ID(+) AND
                  k.tmtb_tmtb_id    = tt.tmtb_id(+) AND
                  tt.trsp_trsp_id   = s_f.trsp_id(+) AND
                  OW.ORWS_TYPE = 1 AND
                  O.ORD_ID = OW.ORD_ORD_ID AND
                  k.KNSM_TYPE = 1 and rownum=1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
			         begin
                  V_SHIP_DEF:=NULL;
			         end;
          END;
        WHEN TOO_MANY_ROWS THEN
		       Begin
              V_SHIP_DEF:=null;
		       end;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<порт прибытия>') > 0) THEN
      BEGIN
         select def  pod_port_id_
           INTO V_PORT_DEF
           from ports
          where port_id in (SELECT pod_port_id
                              FROM KNOR_ORD KD, KNSM_ORDERS KO, KONOSAMENTS K
                             WHERE KD.ORD_ORD_ID=P_ORD_ID AND
                                   KD.KNOR_KNOR_ID = KO.KNOR_ID(+) AND
                                   KO.KNSM_KNSM_ID = K.KNSM_ID(+) and is_custom=1);

      EXCEPTION
        WHEN OTHERS THEN
           V_PORT_DEF:=null;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<город прибытия>') > 0) THEN
      BEGIN
         select def  city_pod_id_
           INTO V_CITY_DEF_POD
           from cities
          where city_id in (SELECT city_pod_id
                              FROM KNOR_ORD KD, KNSM_ORDERS KO, KONOSAMENTS K
                             WHERE KD.ORD_ORD_ID=P_ORD_ID AND
                                   KD.KNOR_KNOR_ID = KO.KNOR_ID(+) AND
                                   KO.KNSM_KNSM_ID = K.KNSM_ID(+) and
                                   is_custom=1) ;
      EXCEPTION
        WHEN OTHERS THEN
           V_CITY_DEF_POD := null;
      END;
    END IF;


    IF (INSTR(V_MSG_INFO, '<ожидаемая дата>') > 0) THEN
      BEGIN
        SELECT NVL(KO.ETA_DATE, K.ETA_DATE)
          INTO V_ETA_DATE
          FROM KNOR_ORD KD, KNSM_ORDERS KO, KONOSAMENTS K, ORDER_WAYS OW
         WHERE OW.ORD_ORD_ID = KD.ORD_ORD_ID(+) AND
               KD.KNOR_KNOR_ID = KO.KNOR_ID(+) AND
               KO.KNSM_KNSM_ID = K.KNSM_ID(+) AND
               P_ORD_ID = OW.ORD_ORD_ID AND
               OW.ORWS_TYPE = 1;
      EXCEPTION
        WHEN OTHERS THEN
           V_ETA_DATE:=NULL;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<дата прибытия>') > 0) THEN
      BEGIN
        SELECT TT.ARRIVAL_DATE
          INTO V_ARRIVAL_DATE
          FROM KNOR_ORD             KD,
               KNSM_ORDERS          KO,
               KONOSAMENTS          K,
               ORDER_WAYS           OW,
               TRANSPORT_TIME_TABLE TT
         WHERE OW.ORD_ORD_ID = KD.ORD_ORD_ID(+) AND
               KD.KNOR_KNOR_ID = KO.KNOR_ID(+) AND
               KO.KNSM_KNSM_ID = K.KNSM_ID(+) AND
               K.TMTB_TMTB_ID = TT.TMTB_ID AND
               P_ORD_ID = OW.ORD_ORD_ID AND
               OW.ORWS_TYPE = 1;
      EXCEPTION
        WHEN OTHERS THEN
           V_ARRIVAL_DATE:=NULL;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<дата убытия>') > 0) THEN
      BEGIN
         select TO_CHAR(CM.PORT_OUT, 'DD.MM.YYYY HH24:MI:SS'), CM.PORT_OUT -- cmrs.PORT_OUT
           into V_PORT_OUT, V_PORT_OUT_df
           from order_ways ow3,cmrs cm
          where ow3.ord_ord_id = P_ORD_ID and
                ow3.orws_type  = 3 and
                ow3.del_date is Null and
                ow3.orws_id = cm.orws_orws_id and
                cm.port_out is not Null and
                cm.del_date is Null and
                cm.cmr_id = (select min(od.cmr_id)
                               from cmrs od
                              where od.orws_orws_id = ow3.orws_id and
                                    od.del_date is Null);
      EXCEPTION
        WHEN OTHERS THEN
           V_PORT_OUT := NULL;
           V_PORT_OUT_df := NULL;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<номер авто>') > 0) OR
       (INSTR(V_MSG_INFO, '<фамилия>') > 0) OR
       (INSTR(V_MSG_INFO, '<телефон>') > 0) THEN
      BEGIN
         select cr.state_number, cm.driver_name, cm.driver_phone
           into V_CAR_NUMBER, V_DRIVER_NAME, V_DRIVER_PHONE
           from order_ways ow3, cmrs cm, cars cr
          where ow3.ord_ord_id = P_ORD_ID and
                ow3.orws_type  = 3 and
                ow3.del_date is Null and
                ow3.orws_id    = cm.orws_orws_id and
                cm.del_date is Null and
                cm.cmr_id = (select max(od.cmr_id)
                               from cmrs od
                              where od.orws_orws_id = ow3.orws_id and
                                    od.del_date is Null) and
                cm.car_car_id  = cr.car_id(+) and
                cm.port_out is not null;
      EXCEPTION
        WHEN OTHERS THEN
           V_CAR_NUMBER := NULL;
           V_DRIVER_NAME := NULL;
           V_DRIVER_PHONE := NULL;
      END;
    END IF;

    -- Проверка, есть такая переменная
    IF (INSTR(V_MSG_INFO, '<внутренний номер заказа>') > 0) THEN
      BEGIN
	    	 select INTERNAL_NUMBER
   		     INTO V_ORD_NAMER  -- Устанавливаем значение
		       From orders o
		      where O.ORD_ID=P_ORD_ID;
      EXCEPTION
        WHEN OTHERS THEN
           V_ORD_NAMER := NULL;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<дата подачи>') > 0) THEN
      BEGIN
         select CP.GTD_DATE
  		     into V_DATE_POD
           from custom_plans CP
          where cp.ord_ord_id  = P_ord_id;
      EXCEPTION
        WHEN OTHERS THEN
          V_DATE_POD:=null;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<планируемая дата прибытия>') > 0) THEN
      BEGIN
	       Select Decode(
	              Decode(NVL(TO_CHAR(DT1),'0'),'0',Decode(NVL(TO_CHAR(DT2),'0'),'0',NVL(TO_CHAR(DT3),'0'),NVL(TO_CHAR(DT2),'0')),NVL(TO_CHAR(DT1),'0'))
	              ,'0',null,
	              Decode(NVL(TO_CHAR(DT1),'0'),'0',Decode(NVL(TO_CHAR(DT2),'0'),'0',NVL(TO_CHAR(DT3),'0'),NVL(TO_CHAR(DT2),'0')),NVL(TO_CHAR(DT1),'0'))) DT
	         INTO V_DATE_PLAN  -- Устанавливаем значение
		       From (select (select MAX(tt.eta_date) DT
		                       FROM transport_time_table tt
		                      where tt.tmtb_id in (select k.tmtb_tmtb_id
		                                             FROM konosaments k
		                                            WHERE k.knsm_id in (select ko.knsm_knsm_id
                                                                      from knor_ord kd, knsm_orders ko
                                                                     where kd.ord_ord_id = P_ORD_ID and
                                                                           kd.knor_knor_id = ko.knor_id
                                                                     group by ko.knsm_knsm_id) AND
                                                      k.del_user is Null and
                                                      k.TMTB_TMTB_ID is not null)) DT1,
					              -- выбираем Океанский коносамент
					              (select  MAX(k.ETA_DATE) DT
	 				                 FROM konosaments k
					                WHERE k.knsm_id in (select ko.knsm_knsm_id
					                                      from knor_ord kd, knsm_orders ko
                                               where kd.ord_ord_id = P_ORD_ID and
                                                     kd.knor_knor_id = ko.knor_id
                                               group by ko.knsm_knsm_id) and
                                k.KNSM_TYPE=2) DT2,
					              -- Из истории
					              (select ow.DATE_PLAN From order_ways ow where ow.ord_ord_id = P_ORD_ID and rownum=1) DT3
		               From dual);
      EXCEPTION
        WHEN OTHERS THEN
          V_DATE_PLAN:=NULL;
      END;
    END IF;

    IF (INSTR(V_MSG_INFO, '<груз по заявке>') > 0) THEN
      BEGIN
     select FREIGHTS.def
       into V_gruz_po_zayavke
       from T_LOADING_PLACES, ORDER_FREIGHTS, FREIGHTS
      where T_LOADING_PLACES.ORD_ORD_ID = P_ord_id
        and T_LOADING_PLACES.LDPL_ID=ORDER_FREIGHTS.LDPL_LDPL_ID
        and ORDER_FREIGHTS.FRGT_FRGT_ID=FREIGHTS.FRGT_ID
        and T_LOADING_PLACES.SOURCE_TYPE=0
        and T_LOADING_PLACES.LDPL_TYPE=0;
      EXCEPTION
        WHEN OTHERS THEN
          V_gruz_po_zayavke:=null;
      END;
    END IF;


    V_MSG_INFO := REPLACE(V_MSG_INFO, '<номер заказа>',V_ORD_NUMBER);
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<дата заказа>', NVL(TO_CHAR(V_ORD_DATE,'dd.mm.yyyy'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<дата выпуска ГТД>', NVL(TO_CHAR(V_DATE_OUT_GTD,'dd.mm.yyyy'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<дата отгрузки>', NVL(TO_CHAR(V_DATE_IN,'dd.mm.yyyy'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<дата выгрузки>',NVL(TO_CHAR(V_VOCH_DATE,'dd.mm.yyyy'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<контейнер>', NVL(V_CONT_NUMBER, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<грузоотправитель>',NVL(V_SHORT_NAME, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<город отправки>',V_CITY_DEF);
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<дата погрузки>',NVL(TO_CHAR(V_DATE_OUT,'dd.mm.yyyy'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<судно>',NVL(V_SHIP_DEF, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<порт прибытия>',V_PORT_DEF);
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<город прибытия>',V_CITY_DEF_POD);
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<ожидаемая дата>',NVL(TO_CHAR(V_ETA_DATE,'dd.mm.yyyy'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<дата прибытия>',NVL(TO_CHAR(V_ARRIVAL_DATE,'dd.mm.yyyy'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<дата убытия>', NVL(TO_CHAR(V_PORT_OUT_df,'dd.mm.yyyy'), 'N/A')); -- used to be V_PORT_OUT
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<номер авто>', NVL(V_CAR_NUMBER, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<фамилия>', NVL(V_DRIVER_NAME, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO, '<телефон>', NVL(V_DRIVER_PHONE, 'N/A'));
    --Замена текста
    V_MSG_INFO := REPLACE(V_MSG_INFO,'<внутренний номер заказа>',NVL(V_ORD_NAMER, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO,'<планируемая дата прибытия>',NVL(TO_CHAR(V_DATE_PLAN,'dd.mm.yyyy'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO,'<склад>',NVL(V_SKLAD, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO,'<номер авто к клиенту>',NVL(V_CAR_NUMBER_C, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO,'<фамилия к клиенту>',NVL( V_DRIVER_NAME_C, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO,'<дата убытия к клиенту>',NVL(TO_CHAR(V_DATE_C, 'DD.MM.YYYY'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO,'<телефон к клиенту>',NVL( V_DRIVER_PHONE_C, 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO,'<дата подачи>',NVL(TO_CHAR(V_DATE_POD, 'DD.MM.YYYY HH24:MI'), 'N/A'));
    V_MSG_INFO := REPLACE(V_MSG_INFO,'<груз по заявке>',NVL( V_gruz_po_zayavke, 'N/A'));


RETURN V_MSG_INFO;
EXCEPTION
  WHEN NO_DATA_FOUND OR TOO_MANY_ROWS THEN
    RETURN 0;
end;

PROCEDURE ADD_Message(P_ORST_ID ORDER_STATUSES.ORST_ID%type,        -- Код статуса
                      P_ORD_ORD_ID ORDERS.ORD_ID%type,              -- Код заказа
                      P_orst_tmms orders.stop_order%type default 0 -- Если P_orst_tmms = 0 то передали ORST_ID, а если P_orst_tmms = 1 то передали TM_ID
					 ) IS
V_clnt_clnt_id number := null;
V_HOLD_HOLD_ID number := null;
V_MESSAGE_TEXT varchar2(2000);
V_STORE_DAYS NUMBER;  -- Срок хранения сообщения
NN number;
clnt_id_to_be_processed client_requests.clnt_clnt_id%type := 0;
V_is_order TEMPLATES_MESSAGES_DIC.is_order%type;
V_clrq_clrq_id messages2customers.clrq_clrq_id%type := null ;
NN_clrq_clrq_id number :=0;
BEGIN
   -- Проверка подписки Клиента на событие
   if P_orst_tmms = 0 then
      select count(ms.clnt_clnt_id||ms.tm_tm_id)
        into clnt_id_to_be_processed
        from MESSAGE_SUBSCRIPTIONS ms
        where ms.clnt_clnt_id in (select cr.clnt_clnt_id
                                    from clrq_orders co, client_requests cr
                                   where co.clrq_clrq_id = cr.clrq_id and
                                         co.ord_ord_id = P_ORD_ORD_ID ) and
              ms.tm_tm_id in (select tm_tm_id
                                from order_statuses
                               where orst_id = P_ORST_ID) and
              ms.del_date is null;
   elsif P_orst_tmms = 1 then
      select count(ms.clnt_clnt_id||ms.tm_tm_id)
        into clnt_id_to_be_processed
        from MESSAGE_SUBSCRIPTIONS ms
       where ms.clnt_clnt_id in (select cr.clnt_clnt_id
                                   from clrq_orders co, client_requests cr
                                  where co.clrq_clrq_id = cr.clrq_id and
                                        co.ord_ord_id = P_ORD_ORD_ID ) and
             ms.tm_tm_id = P_ORST_ID and
             ms.del_date is null;
   end if;

   if clnt_id_to_be_processed > 0 then
      -- Клиент подписан на событие
      -- Проверка на ввод
      IF (trim(P_ORST_ID) IS NULL) THEN
         RaiseError('Не указали статус!!!');
      END IF;
      IF (trim(P_ORD_ORD_ID) IS NULL) THEN
         RaiseError('Не указали заказ!!!');
      END IF;
      -- Проверка на существование шаблона
      Begin
         if P_orst_tmms = 0 then
            select TM.MESSAGES_TEXT, TM.STORE_DAYS, TM.is_order
              INTO V_MESSAGE_TEXT, V_STORE_DAYS, V_is_order   -- Текст сообщения и срок
              from ORDER_STATUSES OS, TEMPLATES_MESSAGES TM
             where OS.ORST_ID=P_ORST_ID and
                   TM.DEL_DATE is null and  OS.TM_TM_ID=TM.TM_ID;
         elsif P_orst_tmms = 1 then
            select TM.MESSAGES_TEXT, TM.STORE_DAYS, TM.is_order
              INTO V_MESSAGE_TEXT, V_STORE_DAYS, V_is_order   -- Текст сообщения и срок
              from TEMPLATES_MESSAGES TM
             where TM.DEL_DATE is null and TM.TM_ID=P_ORST_ID;
       end if;
       -- Проверка на повтор сообщения
       select Count(*) into nn
         from messages2customers MC
        where ord_ord_id = P_ORD_ORD_ID and
              event_id=P_ORST_ID;
       -- 04/05/2016
       -- Убираем лишние отладочные сообщения
       --if nn > 0 then
         -- RaiseError('Cобытие ' || P_ORST_ID || ' у заказа' || P_ORD_ORD_ID || ' уже было!!!');
       --else
       if nn = 0 then
          if (P_ORST_ID=1 and V_is_order=1) then
             -- Предварительная заявка Событие по заказу
             select count( MC.clrq_clrq_id)
               into NN_clrq_clrq_id -- количество заявок Клиентов по текущему заказу
               from clrq_orders co, messages2customers MC
              where co.clrq_clrq_id = MC.clrq_clrq_id and
                    co.ord_ord_id   = P_ORD_ORD_ID and
                    MC.Event_Id=P_ORST_ID;
             if NN_clrq_clrq_id = 0 then
                -- сообщений по заказу еще не было
                begin
                  select distinct co.clrq_clrq_id
                    into V_clrq_clrq_id -- выбор идентификатора заявки Клиента
                    from clrq_orders co, client_requests cr
                   where co.clrq_clrq_id = cr.clrq_id and
                         co.ord_ord_id   = P_ORD_ORD_ID;
                EXCEPTION
                  WHEN OTHERS THEN
                      RaiseError(SQLERRM);
                end;
             end if;
          end if;
          -- Определяем к какому  Холдингу принадлежит Клиент
          select value_string
            into V_HOLD_HOLD_ID
            from app_parameters_dic
           where prmt_id=4;
          if (P_ORST_ID=1 and V_is_order=1 and NN_clrq_clrq_id>=1 ) then
             -- Если тип события "Предварительная заявка", но оно относится к ЗАКАЗУ, а не к заявке, то сообщение формировать не надо
             -- ins_sys_logs(ApplId=>ApplId,Message=>'NOT ins P_ORST_ID='||P_ORST_ID||' V_is_order='||V_is_order||' NN_clrq_clrq_id>='||NN_clrq_clrq_id||' P_ORD_ORD_ID='||P_ORD_ORD_ID||' V_clrq_clrq_id='||V_clrq_clrq_id, IsCommit=>False);
             null;
          else
             begin
                insert into messages2customers
                       (mscm_id,message_date,send_to,clnt_clnt_id,message_text,
                        ord_ord_id,delivery_type, hold_hold_id,send_date,store_days,event_id,orst_tmms,clrq_clrq_id)
                 values
                       (mscm_seq.nextval,sysdate,'message_text',V_CLNT_CLNT_ID,'message_text',P_ORD_ORD_ID,
                        0,V_HOLD_HOLD_ID,null,V_STORE_DAYS,P_ORST_ID,P_orst_tmms,V_clrq_clrq_id);
              --   ins_sys_logs(ApplId=>ApplId,
                --              Message=>'YES ins P_ORST_ID='||P_ORST_ID||' V_is_order='||V_is_order||' NN_clrq_clrq_id>='||NN_clrq_clrq_id||' P_ORD_ORD_ID='||P_ORD_ORD_ID||' V_clrq_clrq_id='||V_clrq_clrq_id,
                  --            IsCommit=>False);
             EXCEPTION
               WHEN OTHERS THEN
                   RaiseError(SQLERRM);
             end;
          end if;
       end if; -- if nn=0 then
    EXCEPTION
       WHEN OTHERS THEN
          RaiseError('Код ошибки '  || SQLERRM ||' Заказ = '||P_ORD_ORD_ID);
    end;
end if; -- Клиент подписан на событие
EXCEPTION
  WHEN OTHERS THEN
    HandleError(SQLCODE, SQLERRM, 'ADD_Message');
END;

-- Обработка сообщения
PROCEDURE EXE_Message(P_MSCM_ID MESSAGES2CUSTOMERS.MSCM_ID%type,  -- Код сообщения
                      P_message_text OUT MESSAGES2CUSTOMERS.message_text%type,  -- Текс сообщения
			          		  P_send_to OUT MESSAGES2CUSTOMERS.send_to%type,  -- Адрес отправителя
					            P_HOLD_HOLD_ID OUT MESSAGES2CUSTOMERS.HOLD_HOLD_ID%type,  -- Холдинг
					            P_CLNT_CLNT_ID OUT MESSAGES2CUSTOMERS.CLNT_CLNT_ID%type,  -- Клиент
                      P_orst_tmms MESSAGES2CUSTOMERS.orst_tmms%type         ,
                      P_tm_ms_def OUT templates_messages.def%type ) IS
V_ORD_ID ORDERS.ORD_ID%type;
begin
  Begin
     if P_orst_tmms = 0 then
        select MC.ORD_ORD_ID, TM.MESSAGES_TEXT, tm.def
          INTO V_ORD_ID,P_message_text, P_tm_ms_def  -- Текст сообщения и срок
          from ORDER_STATUSES OS, TEMPLATES_MESSAGES TM, MESSAGES2CUSTOMERS MC
         where MC.MSCM_ID=P_MSCM_ID AND
               OS.ORST_ID=MC.EVENT_ID and
               TM.DEL_DATE is null and
               OS.TM_TM_ID=TM.TM_ID;
     elsif  P_orst_tmms = 1 then
        select MC.ORD_ORD_ID, TM.MESSAGES_TEXT, tm.def
          INTO V_ORD_ID,P_message_text, P_tm_ms_def   -- Текст сообщения и срок
          from TEMPLATES_MESSAGES TM, MESSAGES2CUSTOMERS MC
         where MC.MSCM_ID=P_MSCM_ID AND
               MC.EVENT_ID = TM.TM_ID and
               TM.DEL_DATE is null;
     end if;
  EXCEPTION
    WHEN OTHERS THEN
       ins_sys_logs(ApplId=>ApplId,Message=>'Не работает выборка из ORDER_STATUSES OS, TEMPLATES_MESSAGES TM, MESSAGES2CUSTOMERS MC, P_MSCM_ID='||P_MSCM_ID||' P_CLNT_CLNT_ID='||P_CLNT_CLNT_ID, IsCommit=>True);
  end;
  /*
  -- Проверка на существование почтового ящика
  SELECT CL.EMAIL, O.CLNT_CLNT_ID
    INTO P_send_to, P_CLNT_CLNT_ID  -- Почта , клиент
    FROM CLIENT_CONTACTS CL, ORDERS O
   WHERE O.ORD_ID = V_ORD_ID
     AND CL.CLCN_ID(+) = O.CLCN_CLCN_ID;
  */
  begin
     Select  c.HOLD_HOLD_ID, c.clnt_id
       INTO P_HOLD_HOLD_ID,  P_CLNT_CLNT_ID
       FROM ORDERS O, clients C
      WHERE O.ORD_ID = V_ORD_ID AND
            O.CLNT_CLNT_ID=C.CLNT_ID AND
            C.DEL_DATE is null;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	      RaiseError('Возможно у заказа клиент помечен на удаление!! V_ORD_ID='||V_ORD_ID);
  end;
  IF (trim(P_HOLD_HOLD_ID) IS NULL) THEN
     RaiseError('У клиента нет холдинга!!!');
  END IF;
  -- Формирование текста сообщения и его темы
  P_MESSAGE_TEXT:=SET_VALUES_MESSAGES(V_ORD_ID, P_MESSAGE_TEXT);
  P_tm_ms_def:=rtrim(Substr(SET_VALUES_MESSAGES(V_ORD_ID, P_tm_ms_def),1,199));

  -- Отправлять письмо или нет
  if INSTR(LOWER(P_MESSAGE_TEXT),LOWER('N/A<NOT>'))<>0 then
      P_MESSAGE_TEXT:='NOT';
	end if;

  if P_MESSAGE_TEXT<>'NOT' then
     P_MESSAGE_TEXT:=REPLACE(P_MESSAGE_TEXT,'<NOT>','');
  end if;
   -- Очистка от ненужных ТЭГОВ
  if P_MESSAGE_TEXT<>'NOT' then
     P_MESSAGE_TEXT:=READ_BODY_MSG_F(P_MESSAGE_TEXT);
   end if;
  null;
end;


FUNCTION READ_BODY_MSG_F(P_MESSAGE_TEXT  MESSAGES2CUSTOMERS.MESSAGE_TEXT%TYPE) RETURN VARCHAR2 IS
str VARCHAR2(32000);
str1 VARCHAR2(32000);
str2 VARCHAR2(32000);
str3 VARCHAR2(32000);
ss varchar2(2000);
tmpVar varchar2(5);
BEGIN
-- Получили строку
  STR:=P_MESSAGE_TEXT;
  str2:=str;
	-- Проверка - отправлять сообщение или нет
    if INSTR(LOWER(str),LOWER('N/A<NOT>'))=0 then
     tmpVar:='1';
	end if;
	str:=REPLACE(str,'<NOT>','');

  LOOP
    str1:=SUBSTR(str2,INSTR(str2,'<b>'),INSTR(str2,'</b>')-INSTR(str2,'<b>')+4);
--
    if (INSTR(str1,'<b>')+INSTR(str1,'</b>'))>=2 Then
-- Проверка
      if INSTR(str1,'N/A&')>=1 then
-- главная переменная пустая
         str:=REPLACE(str,str1,'');
      else
-- выводм все как есть
         ss:=SUBSTR(str1,INSTR(str1,'<b>')+3,INSTR(str1,'</b>')-4);
-- Замена
         str:=REPLACE(str,str1,ss);
      end if;
-- Запись для теста
    end if;
-- Проверка на превышение строки
    if INSTR(str2,'</b>')+4>LENGTH(str2) Then EXIT; end if;
-- Проверка на null
    if NVL(LENGTH(str2),0)=0 Then EXIT; end if;
    str2:=SUBSTR(str2,INSTR(str2,'</b>')+4,LENGTH(str2));
-- Если блоков больше нет
    if (INSTR(str2,'<b>')+INSTR(str2,'</b>'))<2 Then Exit; end if;
  end LOOP;
  IF NVL(LENGTH(STR),0)<>0 Then
-- Обновление в базе
	str:=REPLACE(str,'&','');
	str:=REPLACE(str,'<b>','');
	str:=REPLACE(str,'</b>','');
	str:=REPLACE(str,'b>','');
	str:=REPLACE(str,'<not>','');
	str:=REPLACE(str,'<NOT>','');
	RETURN STR;
  END IF;
END ;


-- Отправка сообщений, которые не отправленны
PROCEDURE SendMessageToMail IS
  V_message_text MESSAGES2CUSTOMERS.message_text%type;
  V_send_to MESSAGES2CUSTOMERS.send_to%type;
  V_send_to_last MESSAGES2CUSTOMERS.send_to%type;
  V_HOLD_HOLD_ID MESSAGES2CUSTOMERS.HOLD_HOLD_ID%type;
  V_CLNT_CLNT_ID MESSAGES2CUSTOMERS.CLNT_CLNT_ID%type;
  V_orst_tmms_SMTM orders.stop_order%type;
  V_tm_ms_def templates_messages.def%type;
  -- V_fl_name client_contacts.last_name%type;
  V_fl_name varchar2(200);
  CL_ID number;
  send_to varchar2(200);
  V_povtor_email number := null;
begin

  For DAN in(select *
             from
               (select MC.MSCM_ID, MC.HOLD_HOLD_ID, MC.send_to,MC.message_thema,MC.message_text,MC.EVENT_ID,MC.CLNT_CLNT_ID,MC.orst_tmms,
                       SBC_MESSAGE.emails2line(o.ORD_ID) cl_Email , row_number() over(order by MC.message_date) nn
                  from messages2customers MC, orders o, CLIENT_CONTACTS CL
                 where mc.ORD_ORD_ID=o.ORD_ID AND CL.CLCN_ID(+) = O.CLCN_CLCN_ID and
                       MC.send_date is null and  -- Письмо не отправленно
                       MC.send_to is not null and -- Нет почтового ящика
                       (MC.message_date+MC.STORE_DAYS) > sysdate and   -- Количество дней отправки сообщения
                       UPPER(MC.message_text)<> 'NOT' and
                       EVENT_ID not in (12009,12008) and
                       (((select COMPLETE_DATE From orders where ORD_ID=MC.ord_ord_id) is null) OR
                       ((select COMPLETE_DATE From orders where ORD_ID=MC.ord_ord_id)>sysdate)) and  -- Заказ не закрыт (дата фактического завершения заказа)
           			       NOT((MC.SEND_TO='message_text') and (Trim(CL.Email) is null))
                 order by MC.message_date)
                 where nn<100) loop
      V_send_to_last := '';
      For emails_id in (
                        select substr(e_m_fl.s,1,instr(e_m_fl.s,'^')-1) e_m , substr(e_m_fl.s,instr(e_m_fl.s,'^')+1) fl
                          from (select regexp_substr(DAN.cl_Email,'[^,]+',1,level) s
                                  from dual
                               connect by regexp_substr(DAN.cl_Email,'[^,]+',1,level) is not null) e_m_fl    ) loop

			   V_message_text:=DAN.message_text;
			   V_send_to:=DAN.send_to;
         V_CLNT_CLNT_ID:=DAN.CLNT_CLNT_ID;
         V_orst_tmms_SMTM:=DAN.orst_tmms;
         V_fl_name:=emails_id.fl;
         V_tm_ms_def := DAN.message_thema;
         V_HOLD_HOLD_ID := DAN.HOLD_HOLD_ID;

         -- Обработать сообщение если не обработанно
	       if (V_message_text='message_text') or (V_send_to='message_text') then
            Begin
	             EXE_Message(P_MSCM_ID=>Dan.MSCM_ID,
                           P_message_text=> V_message_text,
                           P_send_to=>send_to,
                           P_HOLD_HOLD_ID=>V_HOLD_HOLD_ID,
                           P_CLNT_CLNT_ID=>CL_ID,
                           P_orst_tmms=>V_orst_tmms_SMTM,
                           P_tm_ms_def=>V_tm_ms_def);
            EXCEPTION
               WHEN OTHERS THEN
                  ins_sys_logs_autonomous(ApplId => 21,Message => SQLERRM||' Ошибка работы EXE_Message процедуры по MSCM_ID='||Dan.MSCM_ID,LogDate => sysdate);
            end;
         end if;

-- Если у сообщения не проставлен клиет то проставляем
  if (trim(V_CLNT_CLNT_ID) IS NULL) THEN V_CLNT_CLNT_ID:=CL_ID; end if;
  if (trim(V_send_to) IS NULL) OR (trim(V_send_to)='message_text') THEN V_send_to:=emails_id.e_m; end if;

  if V_message_text='NOT' then
	   Begin
       UPDATE messages2customers
	        SET send_date=sysdate,
              send_to=V_send_to,
              message_text=V_message_text,
              HOLD_HOLD_ID=V_HOLD_HOLD_ID,
              CLNT_CLNT_ID=V_CLNT_CLNT_ID,
              message_thema=cast(substr(V_tm_ms_def,1,199) as varchar(200))
        Where MSCM_ID=DAN.MSCM_ID and
              send_date is null;
     EXCEPTION
       WHEN OTHERS THEN
          ins_sys_logs_autonomous(ApplId => 21,
              Message => SQLERRM||' не может сделать UPDATE messages2customers по MSCM_ID='||Dan.MSCM_ID||
                         ' но НЕ ВСЕ параметры определены send_to='||V_send_to_last||' CLNT_CLNT_ID='||V_CLNT_CLNT_ID||
                         ' message_text='||V_message_text||' message_thema='|| V_tm_ms_def,
              LogDate => sysdate);
	End;
	end if;

	if (V_message_text<>'message_text') AND
     (V_send_to<>'message_text')  AND
     (V_message_text<>'NOT')  AND (V_message_text<>'0') Then
     if SBC_SendMail(p_rcvr_name=>V_fl_name, -- 'Клиент',
                     p_rcvr_email=>V_send_to,
                     p_subject=>V_tm_ms_def,
                     p_text=>V_message_text)=0 then
        select instr(V_send_to_last,emails_id.e_m)
          into V_povtor_email
          from dual;
        if V_povtor_email=0 or nvl(V_povtor_email,0)=0 then
           V_send_to_last := ltrim(V_send_to_last||', '||emails_id.e_m,', ');
        end if;
  	    Begin
           UPDATE messages2customers
	            SET send_date=sysdate,
                  send_to=V_send_to_last,
                  message_text=V_message_text,
                  HOLD_HOLD_ID=V_HOLD_HOLD_ID,
                  CLNT_CLNT_ID=V_CLNT_CLNT_ID,
                  message_thema=cast(substr(V_tm_ms_def,1,199) as varchar(200))
            Where MSCM_ID=DAN.MSCM_ID;
        EXCEPTION
          WHEN OTHERS THEN
              ins_sys_logs_autonomous(ApplId => 21,
              Message => SQLERRM||' не может сделать UPDATE messages2customers по MSCM_ID='||Dan.MSCM_ID||
                                  ' но все параметры определены send_to='||V_send_to_last||
                                  ' CLNT_CLNT_ID='||V_CLNT_CLNT_ID||' message_text='||V_message_text||
                                  ' message_thema='|| V_tm_ms_def,
              LogDate => sysdate);
	      End;
	   end if;
  end if;
  commit;
  end loop;
  end loop;

EXCEPTION
   WHEN OTHERS THEN
     HandleError(SQLCODE, SQLERRM, 'SendMessageToMail');
end;

--*************************************************************************************************
-- Deleted the messages from messages2customers table which older then message_date+store_days
--*************************************************************************************************
PROCEDURE Del_old_mails_f_mess2cust IS
begin
   delete from messages2customers
    where message_date+store_days < sysdate ;
   commit;
EXCEPTION
   WHEN OTHERS THEN
     HandleError(-20001,
       ' процедура которая должна была удалить старые сообщения клиентам из таблицы messages2customers НЕ сработала '||rtrim(to_char(sysdate,'dd.mm.yyyy hh24:mi:ss')), 'del_old_mails_f_mess2cust');
end Del_old_mails_f_mess2cust;

--*************************************************************************************************
-- Перевод значений представленных в виде столбца в линейные
--*************************************************************************************************
FUNCTION emails2line(P_ORD_ID IN T_ORDERS.ORD_ID%TYPE)
  RETURN VARCHAR2 IS
  RES VARCHAR2(2000);
BEGIN
  Res := '';
  FOR C IN (select email||'^'||first_name||' '||last_name email
              from client_contacts
             where del_date is null and clcn_id in (select clco.clcn_clcn_id
                                 from orders od, clrq_orders clor, clrq_contacts clco
                                where od.ord_id=clor.ord_ord_id and
                                      clor.clrq_clrq_id=clco.clrq_clrq_id and
                                      clco.send_message = 1 and
                                      clco.del_date is null and
                                      od.ord_id = P_ORD_ID )
                                ORDER BY ROWID ) LOOP
      RES := RES || C.email || ',';
  END LOOP;
  RETURN(RTRIM(RES, ','));
END emails2line;


BEGIN
 Null;
END SBC_MESSAGE;
/
