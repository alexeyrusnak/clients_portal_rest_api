create or replace package SBC_MAIL is


-- Public type declarations
-- Параметры для отправки почты
 MES_EMAIL_FROM varchar2(255);   -- Имя пользователя, от имени которого отправляется почта
 MES_EMAIL_SERVER varchar2(255); -- Имя почтового сервера для отправки сообщений
 MES_EMAIL_PASSW varchar2(255);  -- Пароль пользователя, от которого отправляется почта
 MES_EMAIL_PORT varchar2(50);    -- Порт для почтового сервера
 MES_EMAIL_NAME varchar2(50);    -- Имя владельца (пользователя) почтового ящика
 MES_EMAIL_AUTH boolean ;        -- Использовать авторизацию на сервере
 MES_WALLET_PATH varchar2(2000); -- Путь к кошельку
 MES_WALLET_PASS varchar2(2000); -- Пароль к кошельку

 DISPOSITION_ATTACHMENT CONSTANT VARCHAR2(10) := 'attachment';
 DISPOSITION_INLINE     CONSTANT VARCHAR2(10) := 'inline';
 -- Вложения
 type t_Attachment is record (
   dirname     varchar2(2000),
   filename    varchar2(2000),
   name        varchar2(2000),
   mimetype    varchar2(100),
   blobloc     blob,
   clobloc     clob,
   attachtype  varchar2(100),
   contentid   varchar2(100),
   disposition varchar2(100) default 'attachment'
  );
  type tbl_Attachments is table of t_Attachment;
  attachments tbl_Attachments;

 -- Список получателей письма
 type t_Receiver is record(
   rcvr_name varchar2(500), -- Имя получателя
   rcvr_mail varchar2(500)  -- Мыло получателя
 );
 type tbl_Receivers is table of t_Receiver;

  -- Public function and procedure declarations
  -- Function and procedure implementations
--*************************************************************************************************
-- Clear attachments
--*************************************************************************************************
procedure Prepare;
--*************************************************************************************************
-- Add file-attachment to attachments list to email
--*************************************************************************************************
procedure Add_Attachment(blobloc  IN blob,
                         filename IN varchar2,
                         contentid IN varchar2 default '',
            						 mimetype IN varchar2 DEFAULT 'text/html',
                         disposition IN varchar2 DEFAULT DISPOSITION_ATTACHMENT
                         );
--*************************************************************************************************
-- Перекодировка
--*************************************************************************************************
function Encode_str(str in varchar2,
                    tp  in varchar2 default 'Q') return varchar2;

--*************************************************************************************************
-- Генерация списка получателей
--*************************************************************************************************
function Create_rcvr_list(mailto in varchar2)
                          return tbl_Receivers;
--******************************************************************************************************************************
-- Отправка почты
--******************************************************************************************************************************
function Send_Mail(p_rcvr_email       in varchar2 ,                    -- Список почтовых ящиков адресатов
                   p_rcvr_email_copy  in varchar2 default null,        -- Список адресатор в копии письма
                   p_subject          in varchar2 default null,        -- Тема письма
                   p_text             in varchar2 default null,        -- Текст письма
                   p_appl_id          in applications.appl_id%type,    -- Для какого приложения писать в sys_logs
                   p_sys_log_marker   in varchar2 default null,        -- Метка, которая будет вставляться в sys_logs в начале сообщения
                   P_MES_EMAIL_FROM   in varchar2 default null,        -- Имя пользователя, от имени которого отправляется почта
			             P_MES_EMAIL_NAME   in varchar2 default null,        -- Имя владельца (пользователя) почтового ящика
                   P_MES_EMAIL_SERVER in varchar2 default null,        -- Имя почтового сервера для отправки сообщений
                   P_MES_EMAIL_PASSW  in varchar2 default null,        -- Пароль пользователя, от которого отправляется почта
            			 P_MES_EMAIL_PORT   in varchar2 default null,        -- Порт для почтового сервера
  					       P_MES_EMAIL_AUTH   in boolean default null,         -- Использовать авторизацию на сервере
                   P_MES_WALLET_PATH  in varchar2 default null,        -- Путь к кошельку
                   P_MES_WALLET_PASS  in varchar2 default null         -- Пароль кошелька
                   )
                   Return number;

end SBC_MAIL;
/
create or replace package body SBC_MAIL is

--******************************************************************************************************************************
-- Настройка параметров почты
--******************************************************************************************************************************
PROCEDURE SET_PARAM_EMAIL IS
    CURVAL VARCHAR2(255);
  FUNCTION SET_APP_PARAM(Name_Param VARCHAR2) RETURN varchar2 IS
    Value_Param varchar2(255);
  begin
    begin
    SELECT Trim(VALUE_STRING)
      INTO Value_Param
      FROM APP_PARAMETERS
     WHERE CODE = UPPER(Trim(Name_Param));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	  Value_Param :='-';
    end;
	if Value_Param='-' then  raise_application_error(-20000, 'Не найден настроечный параметр:"'||UPPER(Trim(Name_Param))||'"'||'SET_PARAM_EMAIL');
--	 ins_sys_logs(ApplId=>ApplId,Message=>'Не найден настроечный параметр:"'||UPPER(Trim(Name_Param))||'"');
	end if;
    RETURN Value_Param;
  end;

begin
-- Имя пользователя, от имени которого отправляется почта
  MES_EMAIL_FROM:=SET_APP_PARAM('MES_EMAIL_FROM');
-- Имя почтового сервера для отправки сообщений
  MES_EMAIL_SERVER:=SET_APP_PARAM('MES_EMAIL_SERVER');
-- Пароль пользователя, от которого отправляется почта
  MES_EMAIL_PASSW:=SET_APP_PARAM('MES_EMAIL_PASSW');
-- Порт для почтового сервера
  MES_EMAIL_PORT:=SET_APP_PARAM('MES_EMAIL_PORT');
-- Имя владельца (пользователя) почтового ящика
  MES_EMAIL_NAME:=SET_APP_PARAM('MES_EMAIL_NAME');
-- Использовать авторизацию на сервере
  if SET_APP_PARAM('MES_EMAIL_AUTH')='1' then MES_EMAIL_AUTH := true; else MES_EMAIL_AUTH:=False;
  end if;
-- Путь к кошельку
  MES_WALLET_PATH := SET_APP_PARAM('MES_WALLET_PATH');
-- Адрес кошелька
  MES_WALLET_PASS := SET_APP_PARAM('MES_WALLET_PASS');
end;

--*************************************************************************************************
-- Перекодировка
--*************************************************************************************************
function Encode_str(str in varchar2,
                    tp in varchar2 default 'Q') return varchar2
is
 begin
   if tp='B' then
     RETURN '=?utf-8?b?'|| UTL_RAW.cast_to_varchar2(UTL_ENCODE.base64_encode(UTL_RAW.cast_to_raw (CONVERT (SUBSTR(str,1,24), 'UTF8'))))|| '?='
         || CASE WHEN SUBSTR(str,25) IS NOT NULL THEN utl_tcp.CRLF || ' '|| ENCODE_STR(SUBSTR(str,25),tp) END;
   ELSIF tp='Q' THEN
     RETURN '=?utf-8?q?' || UTL_RAW.cast_to_varchar2(utl_encode.QUOTED_PRINTABLE_ENCODE(utl_raw.cast_to_raw(CONVERT (SUBSTR(str,1,8), 'UTF8') ))) || '?='
         || CASE WHEN SUBSTR(str,9) IS NOT NULL THEN utl_tcp.CRLF || ' '|| ENCODE_STR(SUBSTR(str,9),tp) END;
   ELSE
     RETURN str;
   END IF;
 end;
--*************************************************************************************************
-- Clear attachments
--*************************************************************************************************
 procedure Prepare
 is
 begin
  attachments := tbl_Attachments();
 end;

--*************************************************************************************************
-- Add file-attachment to attachments list to email
--*************************************************************************************************
procedure Add_Attachment(blobloc  IN blob,
                         filename IN varchar2,
                         contentid IN varchar2 default '',
            						 mimetype IN varchar2 DEFAULT 'text/html',
                         disposition IN varchar2 DEFAULT DISPOSITION_ATTACHMENT
                         )
is
 begin
  attachments.extend;
  attachments(attachments.count).name        := filename;
  attachments(attachments.count).contentid   := contentid;
  attachments(attachments.count).mimetype    := mimetype;
  attachments(attachments.count).blobloc     := blobloc;
  attachments(attachments.count).attachtype  := 'BLOB';
  attachments(attachments.count).disposition := disposition; --DISPOSITION_INLINE;-- DISPOSITION_ATTACHMENT;
 end;

--*************************************************************************************************
-- Генерация списка получателей
--*************************************************************************************************
function Create_rcvr_list(mailto in varchar2)
                          return tbl_Receivers
is
  v_mailto VARCHAR2(4096) := replace(mailto,';',',')||',';
  pntr INTEGER;
  buf VARCHAR2(255);
  rcvr_mail VARCHAR2(255);
  rcvr_list tbl_Receivers  := tbl_Receivers();
begin
  FOR maxrcptnts IN 1..50
  LOOP
     pntr:=INSTR(v_mailto,','); buf := substr(v_mailto,1,pntr-1);
     IF pntr>0 THEN
       IF INSTR(buf,'<')>0 AND INSTR(buf,'>')>0 THEN
         rcvr_mail:= SUBSTR(buf,INSTR(buf,'<')+1,INSTR(SUBSTR(buf,INSTR(buf,'<')+1),'>')-1);
         IF rcvr_mail IS NOT NULL THEN
            rcvr_list.extend;
            rcvr_list(rcvr_list.count).rcvr_mail := trim(rcvr_mail);
            rcvr_list(rcvr_list.count).rcvr_name := trim(SUBSTR(buf,1,INSTR(buf,'<')-1));
         END IF;
       ELSE
         rcvr_mail := trim(buf);
         IF rcvr_mail IS NOT NULL THEN
           rcvr_list.extend;
           rcvr_list(rcvr_list.count).rcvr_mail:= trim(rcvr_mail);
         END IF;
       END IF;
     ELSE
       EXIT;
     END IF;
     v_mailto := substr(v_mailto,pntr+1);
   END LOOP;
   RETURN rcvr_list;
end;

--******************************************************************************************************************************
-- Отправка почты
--******************************************************************************************************************************
function Send_Mail(p_rcvr_email       in varchar2 ,                    -- Список почтовых ящиков адресатов
                   p_rcvr_email_copy  in varchar2 default null,        -- Список адресатор в копии письма
                   p_subject          in varchar2 default null,        -- Тема письма
                   p_text             in varchar2 default null,        -- Текст письма
                   p_appl_id          in applications.appl_id%type,    -- Для какого приложения писать в sys_logs
                   p_sys_log_marker   in varchar2 default null,        -- Метка, которая будет вставляться в sys_logs в начале сообщения
                   P_MES_EMAIL_FROM   in varchar2 default null,        -- Имя пользователя, от имени которого отправляется почта
			             P_MES_EMAIL_NAME   in varchar2 default null,        -- Имя владельца (пользователя) почтового ящика
                   P_MES_EMAIL_SERVER in varchar2 default null,        -- Имя почтового сервера для отправки сообщений
                   P_MES_EMAIL_PASSW  in varchar2 default null,        -- Пароль пользователя, от которого отправляется почта
            			 P_MES_EMAIL_PORT   in varchar2 default null,        -- Порт для почтового сервера
  					       P_MES_EMAIL_AUTH   in boolean default null,         -- Использовать авторизацию на сервере
                   P_MES_WALLET_PATH  in varchar2 default null,        -- Путь к кошельку
                   P_MES_WALLET_PASS  in varchar2 default null         -- Пароль кошелька
                   ) Return number
is
 conn               utl_smtp.connection;
 vReply             utl_smtp.reply;
 vReplies           utl_smtp.replies;

 boundary           varchar2(256) := '-----7D81B75CCC90D2974F7A1CBD';
 first_boundary     varchar2(256) := '--'||boundary;
 last_boundary      varchar2(256) := '--'||boundary||'--';
 multipart_mimetype varchar2(256) := 'multipart/mixed; boundary="'||boundary||'"';
-- multipart_mimetype varchar2(256) := 'multipart/related; boundary="'||boundary||'"';
-- multipart_mimetype varchar2(256) := 'multipart/alternative; boundary="'||boundary||'"';

 text_mimetype      varchar2(256) := 'text/html; charset="~"';
 default_RU_cp      varchar2(25) := 'UTF-8';
 local_RU_cp        varchar2(25) := null;
 nn number;
 amt                CONSTANT BINARY_INTEGER := 10368; -- 48bytes binary convert to 128bytes of base64. (32767/2 max for raw convert)
 v_amt              BINARY_INTEGER;
 ps                 BINARY_INTEGER := 1;
 vRAW               RAW(32767);
 vFile              BFILE;
 vBuf               VARCHAR2(32767);
 V_RES              number;
 vEhlo_Mes          varchar2(3000);
 vRcpt_list_to      tbl_Receivers  := tbl_Receivers(); -- Список адресов, кому отправлять
 vRcpt_list_copy    tbl_Receivers  := tbl_Receivers(); -- Список адресов, кому отправлять копии
 vSys_log_marker    varchar2(4000);
begin
 BEGIN
  if p_sys_log_marker is null
   then vSys_log_marker := '';
   else vSys_log_marker := '('||p_sys_log_marker||') ';
  end if;
 --****************************************************************************************************************
    V_RES:=1;
-- Установка переменных из базы ************************************************************************************
    SET_PARAM_EMAIL;
    if (trim(P_MES_EMAIL_FROM) IS NOT NULL)   then MES_EMAIL_FROM   := P_MES_EMAIL_FROM; end if;
    if (trim(P_MES_EMAIL_SERVER) IS NOT NULL) then MES_EMAIL_SERVER := P_MES_EMAIL_SERVER; end if;
    if (trim(P_MES_EMAIL_PASSW) IS NOT NULL)  then MES_EMAIL_PASSW  := P_MES_EMAIL_PASSW; end if;
    if (trim(P_MES_EMAIL_PORT) IS NOT NULL)   then MES_EMAIL_PORT   := P_MES_EMAIL_PORT; end if;
    if (trim(P_MES_EMAIL_NAME) IS NOT NULL)   then MES_EMAIL_NAME   := P_MES_EMAIL_NAME; end if;
    if (P_MES_EMAIL_AUTH IS NOT NULL)         then MES_EMAIL_AUTH   := P_MES_EMAIL_AUTH; end if;
    if (trim(P_MES_WALLET_PATH) IS NOT NULL)  then MES_WALLET_PATH  := P_MES_WALLET_PATH; end if;
    if (trim(P_MES_WALLET_PASS) IS NOT NULL)  then MES_WALLET_PASS  := P_MES_WALLET_PASS; end if;
--*******************************************************************************************************************
 IF MES_WALLET_PATH is null
  THEN
      -- Порт 25
      vReply := utl_smtp.open_connection(host => MES_EMAIL_SERVER,
                                         port => to_Number(MES_EMAIL_PORT),
                                         c    => conn);
/*
      if vReply.code != 220 then
         ins_sys_logs(applid => p_appl_id,
                      message => vSys_log_marker||'utl_smtp.open_connection: '||vReply.code||' - '||vReply.text,
                      iscommit => True);
         return 0;
      end if;
*/
     -- AUTH LOGIN
     if MES_EMAIL_AUTH then
        utl_smtp.ehlo(conn, MES_EMAIL_SERVER);
        utl_smtp.command(conn, 'AUTH LOGIN');
        -- В авторизации подставляем не имя, а ящик отправителя
        utl_smtp.command(conn, utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(MES_EMAIL_FROM))));
        utl_smtp.command(conn, utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(MES_EMAIL_PASSW))));
     end if;
     -- ELHO
     vEhlo_Mes := 'utl_smtp.ehlo';
     vReplies := utl_smtp.ehlo(conn, MES_EMAIL_SERVER);
     --используется для тестирования
    /* for nn IN 1..vReplies.COUNT
      loop
       vEhlo_Mes := vEhlo_Mes||vReplies(nn).code||' - '||vReplies(nn).text;
      end loop;
     ins_sys_logs(applid => p_appl_id,
                  message => vSys_log_marker||vEhlo_Mes,
                  iscommit => True);*/
  ELSE
     -- CONNECTION
     vReply := utl_smtp.open_connection(host => MES_EMAIL_SERVER,
                                        port => to_Number(MES_EMAIL_PORT),
                                        c    => conn,
                                        wallet_path => 'file:'||MES_WALLET_PATH,
                                        wallet_password => MES_WALLET_PASS,
                                        secure_connection_before_smtp => false);

     if vReply.code != 220 then
       ins_sys_logs(applid => p_appl_id,
                    message => vSys_log_marker||'utl_smtp.open_connection: '||vReply.code||' - '||vReply.text,
                    iscommit => True);
       Return 1;
     end if;
     -- AUTO LOGIN
     /*
     if MES_EMAIL_AUTH then
        utl_smtp.ehlo(conn, MES_EMAIL_SERVER);
        utl_smtp.command(conn, 'AUTH LOGIN');
        -- В авторизации подставляем не имя, а ящик отправителя
        utl_smtp.command(conn, utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(MES_EMAIL_FROM))));
        utl_smtp.command(conn, utl_raw.cast_to_varchar2(utl_encode.base64_encode(utl_raw.cast_to_raw(MES_EMAIL_PASSW))));
     end if;
     */
     -- ELHO
     vEhlo_Mes := 'utl_smtp.ehlo';
     vReplies := utl_smtp.ehlo(conn, MES_EMAIL_SERVER);
     --используется для тестирования
     /*
     for nn IN 1..vReplies.COUNT
      loop
       vEhlo_Mes := vEhlo_Mes||vReplies(nn).code||' - '||vReplies(nn).text;
      end loop;
     ins_sys_logs(applid => p_appl_id,
                  message => vSys_log_marker||vEhlo_Mes,
                  iscommit => True);
     */
     -- STARTTLS
     vReply := utl_smtp.starttls(conn);
     if vReply.code != 220 then
       ins_sys_logs(applid => p_appl_id,
                    message => vSys_log_marker||'utl_smtp.starttls: '||vReply.code||' - '||vReply.text,
                    iscommit => True);
       Return 1;
     end if;
     -- ELHO
     vEhlo_Mes := 'utl_smtp.ehlo';
     vReplies := utl_smtp.ehlo(conn, MES_EMAIL_SERVER);
     -- используется для тестирования
     /*
     for nn IN 1..vReplies.COUNT
      loop
       vEhlo_Mes := vEhlo_Mes||vReplies(nn).code||' - '||vReplies(nn).text;
      end loop;
     ins_sys_logs(applid => p_appl_id,
                  message => vSys_log_marker||vEhlo_Mes,
                  iscommit => True);
     */
     --
     vReply := utl_smtp.auth(c => conn,
                             username => MES_EMAIL_FROM,
                             password => MES_EMAIL_PASSW,
                             schemes  => utl_smtp.all_schemes);
     /*
     if vReply.code != 235 then
       ins_sys_logs(applid => p_appl_id,
                    message => vSys_log_marker||'utl_smtp.auth: '||vReply.code||' - '||vReply.text,
                    iscommit => True);
       Return 1;
     end if;*/
 END IF;
 ------
 utl_smtp.mail(conn, MES_EMAIL_FROM);

 -- Формируем список получателей письма
 vRcpt_list_to := Create_rcvr_list(p_rcvr_email);
 for nn IN 1 .. vRcpt_list_to.count
  loop
    utl_smtp.Rcpt(conn, vRcpt_list_to(nn).rcvr_mail);
  end loop;
 vRcpt_list_copy := create_rcvr_list(p_rcvr_email_copy);
 for nn IN 1 .. vRcpt_list_copy.count
  loop
    utl_smtp.Rcpt(conn, vRcpt_list_copy(nn).rcvr_mail);
  end loop;

-- utl_smtp.rcpt(conn, p_rcvr_email);
 -------------------------------------------------------------------------------------------
 utl_smtp.open_data(conn);
 utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('From:'||
                                                   ENCODE_STR(MES_EMAIL_NAME)||'<'||
                                                   MES_EMAIL_FROM||'>'));

 utl_smtp.write_data(conn, utl_tcp.crlf);
 utl_smtp.write_data(conn, 'To: ');
 -- Проставляем имена для получателей
 for nn in 1 .. vRcpt_list_to.count
 loop
   if nn > 1 then
    utl_smtp.write_data(conn, ',');
   end if;
   if vRcpt_list_to(nn).rcvr_name is not null then
     utl_smtp.write_data(conn, Encode_str(vRcpt_list_to(nn).rcvr_name) ||' <'|| vRcpt_list_to(nn).rcvr_mail || '>');
   else
     utl_smtp.write_data(conn, vRcpt_list_to(nn).rcvr_mail);
   end if;
 end loop;
 utl_smtp.write_data(conn, utl_tcp.crlf);

  -- Заполняем список получателей копий письма
 IF vRcpt_list_copy.count > 0
  then
   utl_smtp.write_data(conn, 'CC: ');
   FOR nn IN 1 .. vRcpt_list_copy.count
   LOOP
     if nn > 1 then
      utl_smtp.write_data(conn, ',');
     end if;
     if vRcpt_list_copy(nn).rcvr_name is not null then
       utl_smtp.write_data(conn,
       Encode_str(vRcpt_list_copy(nn).rcvr_name) ||' <'|| vRcpt_list_copy(nn).rcvr_mail || '>');
     else
       utl_smtp.write_data(conn, vRcpt_list_copy(nn).rcvr_mail);
     end if;
   END LOOP;
   utl_smtp.write_data(conn, utl_tcp.crlf);
  end if;
 --*************************************************************************************
 utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw('Subject:'||ENCODE_STR(p_subject)));
 utl_smtp.write_data(conn, utl_tcp.crlf);
 utl_smtp.write_data(conn, 'MIME-version: 1.0'||utl_tcp.CRLF);
 utl_smtp.write_data(conn, 'Content-Type: '||multipart_mimetype||utl_tcp.CRLF);
 utl_smtp.write_data(conn, utl_tcp.crlf);
 utl_smtp.write_data(conn, 'This is a multi-part message in MIME format.' || utl_tcp.CRLF);
 --*************************************************************************************
  begin
   Select VALUE_STRING into local_RU_cp from app_parameters_dic where prmt_id = 2115;
    EXCEPTION
     WHEN OTHERS THEN
        ins_sys_logs(ApplId=>p_appl_id, Message=>vSys_log_marker||'Не работает Select VALUE_STRING into local_RU_cp from app_parameters_dic where prmt_id = 2115', IsCommit=>True);
  end;

 if local_RU_cp is not null then
  default_RU_cp := local_RU_cp ;
 end if;
 select replace( text_mimetype,'~',default_RU_cp) into text_mimetype from dual;

 utl_smtp.write_data(conn, first_boundary||utl_tcp.CRLF);
 utl_smtp.write_data(conn, 'Content-Type: '||text_mimetype||utl_tcp.CRLF);
 utl_smtp.write_data(conn, 'Content-Transfer-Encoding: quoted-printable'||utl_tcp.CRLF);
 utl_smtp.write_data(conn, utl_tcp.crlf);
 utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(p_text));
 utl_smtp.write_data(conn, utl_tcp.crlf);
 --*************************************************************************************
 -- Вложения
 --*************************************************************************************
 IF attachments.count>0 THEN
      FOR x IN 1 .. attachments.count LOOP
            utl_smtp.write_data(conn, '--'|| boundary || utl_tcp.crlf );
            utl_smtp.write_data(conn, 'Content-Type: '||attachments(x).mimetype||';'|| utl_tcp.crlf );
            utl_smtp.write_data(conn, ' name="');
            utl_smtp.write_raw_data(conn,utl_raw.cast_to_raw(attachments(x).name));
            utl_smtp.write_data(conn, '"' || utl_tcp.crlf);
            utl_smtp.write_data(conn, 'Content-Transfer-Encoding: base64'|| utl_tcp.crlf );
--            utl_smtp.write_data(conn, 'Content-ID: <FBC81DE14D9EC3DFA68F293046496D08494C632B> '|| utl_tcp.crlf);
            utl_smtp.write_data(conn, 'Content-ID: <'|| attachments(x).contentid ||'>'|| utl_tcp.crlf );

            IF attachments(x).disposition in (DISPOSITION_ATTACHMENT, DISPOSITION_INLINE) THEN
              utl_smtp.write_data(conn, 'Content-Disposition: '||attachments(x).disposition||';'|| utl_tcp.crlf );
              utl_smtp.write_data(conn, ' filename="');
              utl_smtp.write_raw_data(conn,utl_raw.cast_to_raw(attachments(x).name));
              utl_smtp.write_data(conn, '"' || utl_tcp.crlf);
            END IF;
            utl_smtp.write_data(conn, utl_tcp.crlf);

          IF attachments(x).attachtype = 'FILE' THEN
             vFile := BFILENAME(attachments(x).dirname, attachments(x).filename);
             dbms_lob.fileopen(vFile, dbms_lob.file_readonly);
             ps:=1; v_amt:=amt;
             LOOP
               BEGIN
                 dbms_lob.read (vFile, v_amt, ps, vRAW);
                 ps := ps + v_amt;
                 utl_smtp.write_raw_data(conn, UTL_ENCODE.base64_encode(vRAW));
               EXCEPTION
                 WHEN no_data_found THEN
                   EXIT;
               END;
             END LOOP;
             dbms_lob.fileclose(vFile);
          ELSIF attachments(x).attachtype = 'BLOB' THEN
               dbms_lob.open(attachments(x).blobloc, dbms_lob.file_readonly);
             ps:=1; v_amt:=amt;
             LOOP
               BEGIN
                 dbms_lob.read (attachments(x).blobloc, v_amt, ps, vRAW);
                 ps := ps + v_amt;
                 utl_smtp.write_raw_data(conn, UTL_ENCODE.base64_encode(vRAW));
               EXCEPTION
                 WHEN no_data_found THEN
                   EXIT;
               END;
             END LOOP;
             dbms_lob.close(attachments(x).blobloc);
          ELSIF attachments (x).attachtype = 'CLOB' THEN
             DBMS_LOB.open (attachments (x).clobloc,DBMS_LOB.file_readonly);
             ps := 1; v_amt := amt;
             LOOP
               BEGIN
                 DBMS_LOB.read (attachments (x).clobloc, v_amt, ps, vBuf);
                 ps := ps + v_amt;
                 UTL_SMTP.write_raw_data (conn,UTL_ENCODE.base64_encode ( UTL_RAW.CAST_TO_RAW(vBuf)));
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                    EXIT;
               END;
             END LOOP;
             DBMS_LOB.close (attachments (x).clobloc);
          END IF;

          utl_smtp.write_data(conn, utl_tcp.crlf);
          utl_smtp.write_data(conn, utl_tcp.crlf);
      END LOOP;
    END IF;
 --*************************************************************************************
 utl_smtp.write_data(conn, utl_tcp.crlf);
 utl_smtp.write_data(conn, last_boundary);
 --
 utl_smtp.close_data(conn);
 utl_smtp.quit(conn);
 -- Clear attachments
 Attachments := tbl_Attachments();
 V_Res := 0;
 RETURN V_RES;
exception
when others then
 begin
    Attachments := tbl_Attachments();
    ins_sys_logs(applid => p_appl_id,
                 message => vSys_log_marker||'SBC_Mail.Send_Mail: '||sqlcode||' - '||sqlerrm,
                 iscommit => True);
    V_res := 1;
    Return v_Res;
 end;
end;
end;
--*************************************************************************************************
begin
  Attachments := tbl_Attachments();
end SBC_MAIL;
/
