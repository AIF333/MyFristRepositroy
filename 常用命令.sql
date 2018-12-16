--yeteng  20161218
--用户   sys/hr as DBA   yeteng/yeteng123 as user;
DDL= DROP TRUNCATE CREATE alter   DML= DELETE INSERT UPDATE 
--存储过程中如果没有建表的权限时，在 as 前 加
Authid Current_User

--获取数列
select rownum from dual connect by level<=10  
--刷新系统缓存 --需DBA角色 只是将连接信息执行计划清除  数据缓存还有
alter system flush buffer_cache ;
--查看回滚段  回滚段记录的是反向操作，如 插入 一条记录 X ，redo 记录的是  insert X,undo 记录的是 delete X;
show parameter undo ;
--设置屏幕输出开
set serveroutput on;
--DML = INSERT  UPDATE DELETE 
--sqlplus 进入后调试  跟踪执行计划 显示执行时间  设置行宽
set autotrace on ; 
set autotrace traceonly /explain/ ;--不展现查询结果
set timing on ;
set linesize 1000;

--hint/* */强制全表扫描  /*+index(a)*/ 强制使用索引
select /*+full(a)*/a.msg from yt1 a where a.id=135627  and a.area_code=713 ;
SELECT /*+ Parallel(t,8) */ * FROM a;
--parallel不是函数，/* */在Oracle中是hint，这句sql意思是强行启用并行模式来执行当前SQL，按理是数字越大，执行效率越高，但与CPU个数有关
--建表时不要日志  并行cpu --parallel 3 表示使用3个cpu 
create table fdd nologging parallel 3 as select * from yt_test_data where rownum <=1000000;

--系统捕捉
v_ErrorCode := SQLCODE; --报错代码 
v_ErrorText := SUBSTR(SQLERRM, 1, 200);    
out_msg := SQLERRM; --报错详细
v_delNum:=sql%rowcount;--sql执行记录数 注意 sql 不是自己定义的sz_sql之类而是 系统的关键字 sql

--查看缓存中的sql
select A.SQL_TEXT,A.SQL_ID,A.PARSE_CALLS,A.EXECUTIONS from v$sql a where upper(a.SQL_TEXT) like 'INSERT INTO YT1%HAHA%';
--填充数据 第三个参数不输人默认为 空格
select lpad('abcde',10,'x') from dual;--从左至右 xxxxxabcde;
select rpad('abcde',10,'x') from dual;--从右至左 abcdexxxxx
--设置块的空闲空间占比，对于表结构稳定的占比不用设置很大，可能经常要扩充字段类型的则可以设置大点，避免行迁移
--行迁移过大的表，可以先建备份表，drop重建
alter table yt_201511 pctfree 20 ;

--truncate 分区
alter table PAAA truncate partition pX ;
--分区表的一个分区快速备份出去,注意表结构要一致。改命令是交换数据，如PX原记录1000，mid_table-1 ;执行后则 PX-1，mid_table-1000
--可以多次交换
alter table PAAA exchange partition PX with table mid_table;

--大数据量update更新 ，看执行计划的cost时有可能1的最小，但实际执行1最慢。花费大概是2，3的十倍的时间
1.update a set a.name = (select b.name from b where a.id=b.id ) ;
--此语句会把a表中的记录每条在b表中全量扫描一次，适合 a表数据量不多的情况，否则更新非常慢。
2.update ( select /*+ BYPASS_UJVC*/  a.name name1,b.name name2 from a,b where a.id=b.id) set name1=name2 ;--默认把记录少的表做a表
--此语句会先创建一个临时表，只会扫描b表一次，效率大大提高，此方法会严格要求b表id_no记录唯一，有两种解决方法：
--a./*+ BYPASS_UJVC*/ 会跳过一对多检，缺点 更新的值不可预料， 2.给b表的id建立唯一unique索引
--同时在id列建立索引不会有作用。因是全表更新，走索引还得回表，维护索引
3.用merge 原理同2 

--Merge用法
/*Merge into 详细介绍
MERGE语句是Oracle9i新增的语法，用来合并UPDATE和INSERT语句。
通过MERGE语句，根据一张表或子查询的连接条件对另外一张表进行查询，
连接条件匹配上的进行UPDATE，无法匹配的执行INSERT。
这个语法仅需要一次全表扫描就完成了全部工作，执行效率要高于INSERT＋UPDATE。

语法：
MERGE [INTO [schema .] table [t_alias]
USING [schema .] { table | view | subquery } [t_alias]
ON ( condition )
WHEN MATCHED THEN merge_update_clause
WHEN NOT MATCHED THEN merge_insert_clause;
*/
复制代码

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

--产生 2到10之间的随机整数  用trunc就是1到9
select trunc(dbms_random.value(1,10)) from dual ;
--修改字段de_id为非空，注意修改前的数据不得有空 
alter table yt_department modify  de_id not null ;
--主键/外键的创建和删除
alter table yt_department add constraint pk_yt_d primary key (de_id) ;
alter table yt_person add constraint fk_yt_person_de foreign key (de_id) references yt_department (de_id) ;
alter table yt_department drop constraint pk_yt_d  ;
alter table yt_person drop constraint fk_yt_person_de ;

--over partition 排序，以id1 id2 分组,以value1 value2排序 ，rn 为序列
select a.*,row_number() over (partition by a.id1,a.id2 order by a.value1,a.value2) rn from yt_over_part a ;
--三个分析函数 rank-排序重复排名相同，排名跳跃  dense_rank--排序重复排名相同，排名不跳跃 row_number--排序递增
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


多表关联：
1.两表关联把 量小的表放在后面，oracle将开始扫描最右边的表作为基础班，效率高
2.多表（>2）关联，把三个表的连接交差表放在最右边，效率高

尽量把表和索引放在不同的表空间：方便管理，减少文件碎片，读取效率更高

order by 使用索引条件：
order by 的列必须在同一个索引中 且定义为非空（也可以在where条件中加条件显示指明为非空,如 > 0）

-- Create table 创建全局临时表 基于会话 会话关了数据就没了
create global temporary table YT_SESSION
(
  area_code NUMBER(3),
  area_name VARCHAR2(5),
  id        NUMBER(10),
  msg       VARCHAR2(32)
)
on commit preserve rows;

-- Create table  基于事物 一commit 数据就清空了
create global temporary table YT_trascation
(
  area_code NUMBER(3),
  area_name VARCHAR2(5),
  id        NUMBER(10),
  msg       VARCHAR2(32)
)
on commit delete rows;



  procedure MY_put_line(v_result in varchar2) as
    v_pos Number := 1; --用来记录v_result每行开始字符的位置
  begin
    WHILE v_pos <= LENGTH(v_result) LOOP
      DBMS_OUTPUT.PUT_LINE(SUBSTR(v_result, v_pos, 200));
      v_pos := v_pos + 200;
    END LOOP;
  end;
  
--压缩lob字段 开并行度16
alter table CHNRWDDB.D_CHN_DOCUMENT201807 move lob(FILE_CONTENT) store as (tablespace DATA compress) parallel 16;
-- 释放并行度
alter table CHNRWDDB.D_CHN_DOCUMENT201807 noparallel;
