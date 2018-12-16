--yeteng  20161218
--�û�   sys/hr as DBA   yeteng/yeteng123 as user;
DDL= DROP TRUNCATE CREATE alter   DML= DELETE INSERT UPDATE 
--�洢���������û�н����Ȩ��ʱ���� as ǰ ��
Authid Current_User

--��ȡ����
select rownum from dual connect by level<=10  
--ˢ��ϵͳ���� --��DBA��ɫ ֻ�ǽ�������Ϣִ�мƻ����  ���ݻ��滹��
alter system flush buffer_cache ;
--�鿴�ع���  �ع��μ�¼���Ƿ���������� ���� һ����¼ X ��redo ��¼����  insert X,undo ��¼���� delete X;
show parameter undo ;
--������Ļ�����
set serveroutput on;
--DML = INSERT  UPDATE DELETE 
--sqlplus ��������  ����ִ�мƻ� ��ʾִ��ʱ��  �����п�
set autotrace on ; 
set autotrace traceonly /explain/ ;--��չ�ֲ�ѯ���
set timing on ;
set linesize 1000;

--hint/* */ǿ��ȫ��ɨ��  /*+index(a)*/ ǿ��ʹ������
select /*+full(a)*/a.msg from yt1 a where a.id=135627  and a.area_code=713 ;
SELECT /*+ Parallel(t,8) */ * FROM a;
--parallel���Ǻ�����/* */��Oracle����hint�����sql��˼��ǿ�����ò���ģʽ��ִ�е�ǰSQL������������Խ��ִ��Ч��Խ�ߣ�����CPU�����й�
--����ʱ��Ҫ��־  ����cpu --parallel 3 ��ʾʹ��3��cpu 
create table fdd nologging parallel 3 as select * from yt_test_data where rownum <=1000000;

--ϵͳ��׽
v_ErrorCode := SQLCODE; --������� 
v_ErrorText := SUBSTR(SQLERRM, 1, 200);    
out_msg := SQLERRM; --������ϸ
v_delNum:=sql%rowcount;--sqlִ�м�¼�� ע�� sql �����Լ������sz_sql֮����� ϵͳ�Ĺؼ��� sql

--�鿴�����е�sql
select A.SQL_TEXT,A.SQL_ID,A.PARSE_CALLS,A.EXECUTIONS from v$sql a where upper(a.SQL_TEXT) like 'INSERT INTO YT1%HAHA%';
--������� ����������������Ĭ��Ϊ �ո�
select lpad('abcde',10,'x') from dual;--�������� xxxxxabcde;
select rpad('abcde',10,'x') from dual;--�������� abcdexxxxx
--���ÿ�Ŀ��пռ�ռ�ȣ����ڱ�ṹ�ȶ���ռ�Ȳ������úܴ󣬿��ܾ���Ҫ�����ֶ����͵���������ô�㣬������Ǩ��
--��Ǩ�ƹ���ı������Ƚ����ݱ�drop�ؽ�
alter table yt_201511 pctfree 20 ;

--truncate ����
alter table PAAA truncate partition pX ;
--�������һ���������ٱ��ݳ�ȥ,ע���ṹҪһ�¡��������ǽ������ݣ���PXԭ��¼1000��mid_table-1 ;ִ�к��� PX-1��mid_table-1000
--���Զ�ν���
alter table PAAA exchange partition PX with table mid_table;

--��������update���� ����ִ�мƻ���costʱ�п���1����С����ʵ��ִ��1���������Ѵ����2��3��ʮ����ʱ��
1.update a set a.name = (select b.name from b where a.id=b.id ) ;
--�������a���еļ�¼ÿ����b����ȫ��ɨ��һ�Σ��ʺ� a������������������������·ǳ�����
2.update ( select /*+ BYPASS_UJVC*/  a.name name1,b.name name2 from a,b where a.id=b.id) set name1=name2 ;--Ĭ�ϰѼ�¼�ٵı���a��
--�������ȴ���һ����ʱ��ֻ��ɨ��b��һ�Σ�Ч�ʴ����ߣ��˷������ϸ�Ҫ��b��id_no��¼Ψһ�������ֽ��������
--a./*+ BYPASS_UJVC*/ ������һ�Զ�죬ȱ�� ���µ�ֵ����Ԥ�ϣ� 2.��b���id����Ψһunique����
--ͬʱ��id�н����������������á�����ȫ����£����������ûر�ά������
3.��merge ԭ��ͬ2 

--Merge�÷�
/*Merge into ��ϸ����
MERGE�����Oracle9i�������﷨�������ϲ�UPDATE��INSERT��䡣
ͨ��MERGE��䣬����һ�ű���Ӳ�ѯ����������������һ�ű���в�ѯ��
��������ƥ���ϵĽ���UPDATE���޷�ƥ���ִ��INSERT��
����﷨����Ҫһ��ȫ��ɨ��������ȫ��������ִ��Ч��Ҫ����INSERT��UPDATE��

�﷨��
MERGE [INTO [schema .] table [t_alias]
USING [schema .] { table | view | subquery } [t_alias]
ON ( condition )
WHEN MATCHED THEN merge_update_clause
WHEN NOT MATCHED THEN merge_insert_clause;
*/
���ƴ���

merge into users
using doctor
on (users.user_id = doctor.doctorid)
when matched then
  update set users.user_name = doctor.doctorname
when not matched then
  insert
  values
    (doctor.doctorid,
     doctor.doctorid,
     '8736F1C243E3B14941A59FF736E1B5A8',
     doctor.doctorname,
     sysdate,
     'T',
     ' ',
     doctor.deptid,
     'b319dac7-2c5c-496a-bc36-7f3e1cc066b8');

--���� 2��10֮����������  ��trunc����1��9
select trunc(dbms_random.value(1,10)) from dual ;
--�޸��ֶ�de_idΪ�ǿգ�ע���޸�ǰ�����ݲ����п� 
alter table yt_department modify  de_id not null ;
--����/����Ĵ�����ɾ��
alter table yt_department add constraint pk_yt_d primary key (de_id) ;
alter table yt_person add constraint fk_yt_person_de foreign key (de_id) references yt_department (de_id) ;
alter table yt_department drop constraint pk_yt_d  ;
alter table yt_person drop constraint fk_yt_person_de ;

--over partition ������id1 id2 ����,��value1 value2���� ��rn Ϊ����
select a.*,row_number() over (partition by a.id1,a.id2 order by a.value1,a.value2) rn from yt_over_part a ;
--������������ rank-�����ظ�������ͬ��������Ծ  dense_rank--�����ظ�������ͬ����������Ծ row_number--�������
create table s_score
( s_id number(6)
 ,score number(4,2)
);
insert into s_score values(001,98);
insert into s_score values(002,66.5);
insert into s_score values(003,99);
insert into s_score values(004,98);
insert into s_score values(005,98);
insert into s_score values(006,80);

select
    s_id 
   ,score
   ,rank() over(order by score desc) rank
   ,dense_rank() over(order by score desc) dense_rank
   ,row_number() over(order by score desc) row_number
from s_score;


��������
1.��������� ��С�ı���ں��棬oracle����ʼɨ�����ұߵı���Ϊ�����࣬Ч�ʸ�
2.���>2��������������������ӽ����������ұߣ�Ч�ʸ�

�����ѱ���������ڲ�ͬ�ı�ռ䣺������������ļ���Ƭ����ȡЧ�ʸ���

order by ʹ������������
order by ���б�����ͬһ�������� �Ҷ���Ϊ�ǿգ�Ҳ������where�����м�������ʾָ��Ϊ�ǿ�,�� > 0��

-- Create table ����ȫ����ʱ�� ���ڻỰ �Ự�������ݾ�û��
create global temporary table YT_SESSION
(
  area_code NUMBER(3),
  area_name VARCHAR2(5),
  id        NUMBER(10),
  msg       VARCHAR2(32)
)
on commit preserve rows;

-- Create table  �������� һcommit ���ݾ������
create global temporary table YT_trascation
(
  area_code NUMBER(3),
  area_name VARCHAR2(5),
  id        NUMBER(10),
  msg       VARCHAR2(32)
)
on commit delete rows;



  procedure MY_put_line(v_result in varchar2) as
    v_pos Number := 1; --������¼v_resultÿ�п�ʼ�ַ���λ��
  begin
    WHILE v_pos <= LENGTH(v_result) LOOP
      DBMS_OUTPUT.PUT_LINE(SUBSTR(v_result, v_pos, 200));
      v_pos := v_pos + 200;
    END LOOP;
  end;
  
--ѹ��lob�ֶ� �����ж�16
alter table CHNRWDDB.D_CHN_DOCUMENT201807 move lob(FILE_CONTENT) store as (tablespace DATA compress) parallel 16;
-- �ͷŲ��ж�
alter table CHNRWDDB.D_CHN_DOCUMENT201807 noparallel;
