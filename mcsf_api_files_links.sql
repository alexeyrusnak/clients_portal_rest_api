create table mcsf_api_files_links
(
  link_token varchar2(40),
  create_date date,
  session_id varchar2(40),
  token varchar2(40),
  params varchar2(255)
);

alter table mcsf_api_files_links add constraint link_token_pk primary key (link_token) using index;
