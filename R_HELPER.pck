create or replace package R_HELPER is

/******************************************************************************
   NAME:       R_HELPER
   PURPOSE: Различные вспомогательные функции

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        23.03.2018  R-abik           1. Создан пакет.

******************************************************************************/

  /*
  Разбивает сроку в массив
  */
  function SplitString(pStr in varchar2, pDelimeter in varchar2 default ',') return t_infinity_str;

end R_HELPER;
/
create or replace package body R_HELPER is

  function SplitString(pStr in varchar2, pDelimeter in varchar2 default ',') return t_infinity_str is
    
    lStr  long default pStr || pDelimeter;
    lN    number;
    lArr t_infinity_str := t_infinity_str();
    
  begin
    loop
      
      lN := instr(lStr, pDelimeter);
      
      exit when(nvl(lN, 0) = 0);
      
      lArr.extend;
      
      lArr(lArr.count) := ltrim(rtrim(substr(lStr, 1, lN - 1)));
      
      lStr := substr(lStr, lN + 1);
    
    end loop;
    
    return lArr;
  
  end;
end R_HELPER;
/
