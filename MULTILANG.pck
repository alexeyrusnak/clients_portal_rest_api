CREATE OR REPLACE PACKAGE MULTILANG IS

  -- Author  : Мараховский Роман борисович
  -- Created : 30.03.2008 12:12:13
  -- Purpose : Пакет работы с мультиязычнымии справочниками

  DEF CONSTANT VARCHAR2(2) := 'RU';

  -- Установить язык текущей сессии
  PROCEDURE SET_LANGUAGE(LANG IN VARCHAR2 DEFAULT DEF);

  -- Получить язык текщей сессии
  FUNCTION GET_LANGUAGE RETURN VARCHAR2;

  -- Установить значение для соответствующего языка формирует строку XML
  -- где XM - входной текст XML
  -- VAL значение которое надо установить
  -- lang - язык который надо использовать

  -- Возвращает сформированый XML для записи в столбец
  FUNCTION SET_LANGUAGE_CAP(XM          in varchar2,
                            VAL         in varchar2,
                            lang        in varchar2 default GET_LANGUAGE,
                            en_trscript in number default 1) return varchar2;
  -- Получить значение для соответствующего языка
  -- где XM - входной текст XML
  -- lang - язык который надо использовать
  FUNCTION GET_LANGUAGE_CAP(XM   in varchar2,
                            lang in varchar2 default GET_LANGUAGE)
  return varchar2 deterministic;

  function RU_ENG_TRANSCRIPT(text in varchar2) return varchar2;

  procedure set_error_code(code in varchar2,
                           val  in varchar2,
                           lang in varchar2 default GET_LANGUAGE);

  procedure set_error_code_num(code in varchar2,
                               val  in varchar2,
                               num_err_code in integer,
                               lang in varchar2 default GET_LANGUAGE);

  function get_error_code(code in varchar2,
                          lang in varchar2 default GET_LANGUAGE)
  return varchar2;

  -- Форматирование строки аналогично Format в Delphi
  function Format(FormatStr varchar2, S1 varchar2,
    S2 varchar2 := '', S3 varchar2 := '', S4 varchar2 := '',
    S5 varchar2 := '', S6 varchar2 := '', S7 varchar2 := '',
    S8 varchar2 := '', S9 varchar2 := '', S10 varchar2 := ''
  ) return varchar2;

END MULTILANG;
/
CREATE OR REPLACE PACKAGE BODY MULTILANG IS

  CURR_LANG VARCHAR(8):= NULL;

  PROCEDURE SET_LANGUAGE(LANG IN VARCHAR2 DEFAULT DEF) IS
  BEGIN
    sys.dbms_session.set_context(sys_context('USERENV', 'CURRENT_SCHEMA')||'_MLNG', 'MLANG', LANG);
    CURR_LANG:= LANG;
  END;

  FUNCTION GET_LANGUAGE RETURN VARCHAR2 IS
  BEGIN
    IF (CURR_LANG IS NULL) THEN
      SELECT sys_context(sys_context('USERENV', 'CURRENT_SCHEMA') || '_MLNG', 'MLANG')
        INTO CURR_LANG
        FROM DUAL;
    END IF;
    RETURN NVL(CURR_LANG, DEF);
  END;

  -- Установить значение для соответствующего языка
  FUNCTION SET_LANGUAGE_CAP(XM          in varchar2,
                            VAL         in varchar2,
                            lang        in varchar2 default GET_LANGUAGE,
                            en_trscript in number default 1) return varchar2 is

    res  varchar2(2000);
    pos1 number;
    pos2 number;
    str1 varchar2(2000);
  begin

    -- Если мультиязычная запись пока пуста
    pos1 := INSTR(XM, '<CAP>', 1, 1);
    if ((XM is null) or (nvl(pos1, 0) = 0)) then
      res := '<CAP><' || upper(lang) || '>' || VAL || '</' || upper(lang) ||
             '></CAP>';
    else

      pos1 := INSTR(XM, '<' || lang || '>', 1, 1);

      -- Если значение на данном языке отсутствует то необходимо вставить
      if nvl(pos1, 0) = 0 then
        str1 := '<' || upper(lang) || '>' || VAL || '</' || upper(lang) || '>';
        pos1 := INSTR(XM, '</CAP>', 1, 1);
        res  := SUBSTR(XM, 1, pos1 - 1) || str1 || '</CAP>';
        -- Если значение на данном языке есть то необходимо заменить
      else
        pos1 := pos1 + 4;
        pos2 := INSTR(XM, '</' || lang || '>', 1, 1);
        res  := SUBSTR(XM, 1, pos1 - 1) || VAL ||
                SUBSTR(XM, pos2, length(XM) - pos2 + 1);

      end if;

    end if;

    if lang = 'RU' and en_trscript = 1 then
      pos1 := INSTR(XM, '<EN>', 1, 1);
      if nvl(pos1, 0) = 0 then
        res := SET_LANGUAGE_CAP(res, RU_ENG_TRANSCRIPT(VAL), 'EN', 0);
      end if;
    end if;

    if lang = 'EN' and en_trscript = 1 then
      pos1 := INSTR(XM, '<RU>', 1, 1);
      if nvl(pos1, 0) = 0 then
        res := SET_LANGUAGE_CAP(res, VAL, 'RU', 0);
      end if;
    end if;

    return res;
  end;

  FUNCTION GET_LANGUAGE_CAP(XM   in varchar2,
                            lang in varchar2 default GET_LANGUAGE)
    return varchar2 deterministic is

    res  varchar2(2000);
    pos1 number;
    pos2 number;
    str1 varchar2(2000);
  Begin

    -- Если мультиязычная запись пока пуста
    if XM is null then
      res := null;
    else
      pos1 := INSTR(XM, '<' || lang || '>', 1, 1);

      -- Если значение на данном языке отсутствует то необходимо на языке по умолчанию
      if pos1 = 0 then
        pos1 := INSTR(XM, '<' || def || '>', 1, 1);
        pos1 := pos1 + 4;
        pos2 := INSTR(XM, '</' || def || '>', 1, 1);
        res  := SUBSTR(XM, pos1, pos2 - pos1);
        -- Если значение на данном языке есть то необходимо найти его
      else
        pos1 := pos1 + 4;
        pos2 := INSTR(XM, '</' || lang || '>', 1, 1);
        res  := SUBSTR(XM, pos1, pos2 - pos1);

      end if;

    end if;
    return res;

  End;

  function RU_ENG_TRANSCRIPT(text in varchar2) return varchar2 is
    res varchar(2000);
  begin
    res := text;
    res := translate(res,
                     'абвгдезиклмнопрстуфцъыь',
                     'abvgdeziklmnoprstufc"y`');
    res := replace(res, 'ё', 'jo');
    res := replace(res, 'ж', 'zh');
    res := replace(res, 'й', 'jj');
    res := replace(res, 'х', 'kh');
    res := replace(res, 'ч', 'ch');
    res := replace(res, 'ш', 'sh');
    res := replace(res, 'щ', 'shh');
    res := replace(res, 'э', 'eh');
    res := replace(res, 'ю', 'ju');
    res := replace(res, 'я', 'ja');
    res := replace(res, 'ь', '');

    ------------------------------------
    res := translate(res,
                     'АБВГДЕЗИКЛМНОПРСТУФЦъЫь',
                     'ABVGDEZIKLMNOPRSTUFC"Y`');

    res := replace(res, 'Ё', 'Jo');
    res := replace(res, 'Ж', 'Zh');
    res := replace(res, 'Й', 'Jj');
    res := replace(res, 'Х', 'Kh');
    res := replace(res, 'Ч', 'Ch');
    res := replace(res, 'Ш', 'Sh');
    res := replace(res, 'Щ', 'Shh');
    res := replace(res, 'Э', 'Eh');
    res := replace(res, 'Ю', 'Ju');
    res := replace(res, 'Я', 'Ja');
    res := replace(res, 'Ь', '');
    return res;
  end;

  procedure set_error_code(code in varchar2,
                           val  in varchar2,
                           lang in varchar2 default GET_LANGUAGE)
  is
    dat varchar2(2040);
  begin

    begin
      select error_text
        into dat
        from mlng_error_codes c
       where c.error_code = code;

      update mlng_error_codes c
         set error_text = SET_LANGUAGE_CAP(dat, val, lang, 1)
       where c.error_code = code;

    exception
      when no_data_found then
        insert into mlng_error_codes
          (merc_id, error_code, error_text)
        values
          (MERC_SEQ.Nextval, code, SET_LANGUAGE_CAP(null, val, lang, 1));
    end;

  end;

  procedure set_error_code_num(code in varchar2,
                               val  in varchar2,
                               num_err_code in integer,
                               lang in varchar2 default GET_LANGUAGE)
  is
    dat varchar2(2040);
  begin

    begin
      select error_text
        into dat
        from mlng_error_codes c
       where c.error_code = code;

      update mlng_error_codes c
         set error_text = SET_LANGUAGE_CAP(dat, val, lang, 1),
             c.num_code = num_err_code
       where c.error_code = code;

    exception
      when no_data_found then
        insert into mlng_error_codes
          (merc_id, error_code, error_text, num_code)
        values
          (MERC_SEQ.Nextval, code, SET_LANGUAGE_CAP(null, val, lang, 1), num_err_code);
    end;

  end;

  Function get_error_code(code in varchar2,
                          lang in varchar2 default GET_LANGUAGE)
    return varchar2 is
    dat varchar2(2040);
  begin

    select GET_LANGUAGE_CAP(error_text, lang)
      into dat
      from mlng_error_codes c
     where c.error_code = code;
    return dat;
  exception
    when no_data_found then
      return null;
  end;

-- Форматирование строки аналогично Format в Delphi
function Format(FormatStr varchar2, S1 varchar2,
  S2 varchar2 := '', S3 varchar2 := '', S4 varchar2 := '',
  S5 varchar2 := '', S6 varchar2 := '', S7 varchar2 := '',
  S8 varchar2 := '', S9 varchar2 := '', S10 varchar2 := ''
) return varchar2
is
  Fs varchar2(2000) := FormatStr;
  Pos int;
  Res varchar2(2000);
  ArgIndex int := 0;
  Value varchar2(2000);
  i int;

  function GetArg return varchar2
  is
  begin
    ArgIndex:= ArgIndex+1;
    if    ArgIndex = 1  then return S1;
    elsif ArgIndex = 2  then return S2;
    elsif ArgIndex = 3  then return S3;
    elsif ArgIndex = 4  then return S4;
    elsif ArgIndex = 5  then return S5;
    elsif ArgIndex = 6  then return S6;
    elsif ArgIndex = 7  then return S7;
    elsif ArgIndex = 8  then return S8;
    elsif ArgIndex = 9  then return S9;
    elsif ArgIndex = 10 then return S10;
    else                     return null;
    end if;
  end GetArg;

  function NumberToHex(Value int, Digits int := null) return varchar2
  is
    sHexDigits constant varchar2(16) := '0123456789ABCDEF';
    N int := Value;
    H varchar2(512);
  begin
    if N is not null then
      while N > 0 or H is null loop
        H := substr(sHexDigits, mod(N,16) + 1, 1) || H;
        N := trunc(N / 16);
      end loop;
      if length(H) < Digits then
        H := lpad(H, Digits, '0');
      end if;
    end if;
    return H;
  end NumberToHex;

  function Parse return boolean
  is
    LeftAligned boolean := false;
    Width int;
    Precision int;
    FmtType char;
    function Ch return char
    is
    begin
      return substr(Fs, i, 1);
    end Ch;
    function ReadInt return int
    is
      n int;
    begin
      while instr('0123456789', Ch) > 0 loop
        n := nvl(n, 0) * 10 + to_number(Ch);
        i:= i+1;
      end loop;
      return n;
    end ReadInt;
  begin
    if Ch = '-' then
      LeftAligned := true;
      i:= i + 1;
    end if;
    Width := ReadInt;
    if Ch = '.' then
      i:= i + 1;
      Precision := ReadInt;
    end if;
    FmtType := Ch;
    i:= i + 1;
    if FmtType = 's' then
      Value := GetArg;
      if Precision is not null then
        Value := substr(Value, 1, Precision);
      end if;
    elsif FmtType in ('d', 'x') then
      Value := GetArg;
      declare
        n int;
      begin
        n := to_number(Value);
        if FmtType = 'd' then
          if Precision is not null then
            Value := to_char(n, 'fm' || rpad('0', Precision, '0'));
            if instr(Value, '#') > 0 then
              Value := to_char(n);
            end if;
          else
            Value := to_char(n);
          end if;
        else
          Value := NumberToHex(n, Precision);
        end if;
      exception
        when value_error then null;
      end;
    else
      return false;
    end if;
    if length(Value) < Width then
      if LeftAligned then
        Value := rpad(Value, Width);
      else
        Value := lpad(Value, Width);
      end if;
    end if;
    return true;
  end;

begin
  loop
    Pos := nvl(instr(Fs, '%'), 0);
    exit when Pos = 0;
    Res := Res || substr(Fs, 1, Pos - 1);
    Fs := substr(Fs, Pos + 1);
    i := 1;
    if Parse then
      Res := Res || Value;
      Fs := substr(Fs, i);
    else
      Res := Res || '%';
    end if;
  end loop;
  return Res || Fs;
end Format;

END MULTILANG;
/
