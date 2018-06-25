-- Create table
create table REST_API_LOG
(
  log_date DATE,
  log      CLOB
)
tablespace SYSAUX
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
