use empregados;
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- inicio questão 1

alter table dept_emp drop index idx_dept_emp_date; 
alter table salaries drop index idx_salaries_emp_date;
	
-- fim questão 1

-- INICIO QUESTÃO 2 

select concat(e.first_name, ' ', e.last_name) Nome, 
			s_ext.salary Salario, 
            d_ext.dept_name Departamento, 
			t_ext.title Cargo, 
            min(dept_ext.from_date) Admissao
from employees e 
join dept_manager dept_ext on dept_ext.emp_no = e.emp_no
join departments d_ext on dept_ext.dept_no = d_ext.dept_no
join salaries s_ext on s_ext.emp_no = e.emp_no
join titles t_ext on t_ext.emp_no = e.emp_no
where dept_ext.to_date = (select max(dept_int.to_date) 
											from dept_manager dept_int 
                                            where dept_int.emp_no = dept_ext.emp_no)
and s_ext.to_date = (select max(s_int.to_date) 
								  from salaries s_int 
                                  where s_int.emp_no = s_ext.emp_no)
and t_ext.to_date = (select max(t_int.to_date) 
								 from titles t_int
                                 where t_int.emp_no = t_ext.emp_no)
group by Departamento;


-- FIM QUESTÃO 2 

-- INICIO QUESTÃO 3

with ultimoDept as(
	select emp_no,
				max(to_date) as max_dept_data
	from dept_manager
    group by emp_no
),

ultimoCargo as (
    select emp_no, 
           max(to_date) as max_cargo_data
    from titles 
    group by emp_no
),

ultimoSalario as (
    select emp_no, 
           max(to_date) as max_salario_data 
    from salaries 
    group by emp_no
)

select concat(emp.first_name, ' ', emp.last_name) Nome, 
    s.salary Salario, 
    dept.dept_name Departamento, 
    t.title Cargo, 
   min( dm.from_date) Admissao
from employees emp 
join ultimoDept ud on emp.emp_no = ud.emp_no
join dept_manager dm on emp.emp_no = dm.emp_no and dm.to_date = ud.max_dept_data
join ultimoSalario us on emp.emp_no = us.emp_no
join salaries s on emp.emp_no = s.emp_no and s.to_date = us.max_salario_data
join ultimoCargo uc on emp.emp_no = uc.emp_no
join titles t on emp.emp_no = t.emp_no and t.to_date = uc.max_cargo_data
join departments dept on dept.dept_no = dm.dept_no
group by Departamento;

-- FIM QUESTÃO 3

-- INICIO QUESTÃO 4

create index idx_depto on departments(dept_no); -- primeiro index criado
create index idx_dept_magr_date on dept_manager(emp_no, to_date); -- segundo index criado
create index idx_salaries_emp_date on salaries(emp_no, to_date); -- terceiro index criado
create index idx_titles_emp_date on titles(emp_no, to_date); -- quarto index criado

-- FIM QUESTÃO 4

-- INICIO QUESTÃO 5

use bd2024;

	-- letra a
		create table departamento(
			depnum char(4) primary key, 
			depnome varchar(40)
		);
        
        alter table funcionario add column fundepnum char(4);
		alter table funcionario add constraint foreign key (fundepnum) references departamento(depnum);
        insert into departamento select * from empregados.departments;
        
        -- letra b
			
            select * from departamento;
            select * from funcionario;
            desc funcionario;
            desc empregados.employees;
            desc empregados.salaries;
            select max(salary) from empregados.salaries;
            alter table funcionario modify column funsalario double(8,2) not null;
            alter table funcionario modify column funsalario double(9,2) not null;
            alter table funcionario modify column funsalario double(10,2) not null;
			select *from bairro;
			select * from estadocivil;
            
            delimiter ##
				create procedure sp_importar_funcionario()
					begin
						
                        declare v_contador int unsigned default 0;
						declare v_funnome varchar(50) default '';
						declare v_funsalario decimal(10,2) default 0;
						declare v_funbaicodigo, v_funcodgerente, v_funestcodigo int unsigned default 0;
						declare v_fundtdem, v_fundtnascto, v_fundtadmissao, v_dtdem date default null;
                        declare v_funsenha varchar(20) default null;
                        declare v_funlogin varchar(30) default null;
						declare v_funsexo char(1) default '';
						declare v_fundepnum char(4) default '';
						declare v_acabou boolean default false;
						
                        declare v_cursor cursor for
							select concat(e.first_name, ' ', e.last_name) Nome, 
									   s_ext.salary Salario, 
                                       d_ext.to_date Demissao, 
                                       d_ext.from_date Admissao, 
									   e.birth_date Nascimento, 
									   e.gender Sexo, 
                                       d_ext.dept_no CodigoDepart  
							from empregados.employees e
							join empregados.dept_emp d_ext on e.emp_no = d_ext.emp_no
							join empregados.salaries s_ext on e.emp_no = s_ext.emp_no
							where	d_ext.to_date = (select max(d_int.to_date)
																   from empregados.dept_emp d_int 
                                                                   where d_int.emp_no = d_ext.emp_no)
							and 	s_ext.to_date = (select max(s_int.to_date)
															   from empregados.salaries s_int
                                                               where s_int.emp_no = s_ext.emp_no);
						declare exit handler for not found set v_acabou = true;
                            
						set v_contador = (select max(funcodigo) from funcionario) +1 ;
                        
                        open v_cursor;
                        
							while not v_acabou do
								fetch v_cursor into v_funnome, v_funsalario, v_dtdem, v_fundtadmissao,
																v_fundtnascto, v_funsexo, v_fundepnum;
								if v_dtdem = '9999-01-01' then
									set v_fundtdem = null;
								else
									set v_fundtdem = v_dtdem;
								end if;
                        
								if lower(substring(v_funnome, 1, 1)) IN ('a', 'b', 'c', 'd', 'e') then
									set	v_funbaicodigo = '12';
									set v_funcodgerente = '2';
									set v_funestcodigo = '2';
								elseif lower(substring(v_funnome, 1, 1)) IN ('f', 'g', 'h', 'i', 'j') then
									set	v_funbaicodigo = '15';
									set v_funcodgerente = '1';
									set v_funestcodigo = '2';
								elseif lower(substring(v_funnome, 1, 1)) IN ('k', 'l', 'm', 'n', 'o') then
									set	v_funbaicodigo = '13';
									set v_funcodgerente = '4';
									set v_funestcodigo = '3';
								elseif lower(substring(v_funnome, 1, 1)) IN ('p', 'q', 'r', 's', 't') then
									set	v_funbaicodigo = '13';
									set v_funcodgerente = '3';
									set v_funestcodigo = '4';
								else 
									set	v_funbaicodigo = '5';
									set v_funcodgerente = '3';
									set v_funestcodigo = '1';
								end if;
                                
                                insert funcionario(funcodigo, funnome, funsalario, funbaicodigo, funcodgerente, fundtdem, funestcodigo, funsenha, funlogin,
															 fundtnascto, fundtadmissao, funsexo, fundepnum)
								value (v_contador, v_funnome, v_funsalario, v_funbaicodigo, v_funcodgerente, v_fundtdem, v_funestcodigo,
										   v_funsenha, v_funlogin, v_fundtnascto, v_fundtadmissao, v_funsexo, v_fundepnum );
								set v_contador = v_contador +1;
							end while;
                        close v_cursor;
                        
                        end ##
	
			delimiter ;

select * from funcionario;
select count(emp_no) from empregados.employees;
drop procedure sp_importar_funcionario;
call sp_importar_funcionario();
select * from funcionario;

update  funcionario set fundepnum = 'd001' where funcodigo <= 20 ;
update  funcionario set fundepnum = 'd004' where funcodigo >20 and funcodigo<=32 ;


-- FIM QUESTÃO 5


-- INICIO QUESTÃO 6

select * from departamento;

create user 'usuariodep1'@'localhost' identified by 'usuariodep1s';
create user 'usuariodep2'@'localhost' identified by 'usuariodep2s';
create user 'usuariodep3'@'localhost' identified by 'usuariodep3s';
create user 'usuariodep4'@'localhost' identified by 'usuariodep4s';
create user 'usuariodep5'@'localhost' identified by 'usuariodep5s';
create user 'usuariodep6'@'localhost' identified by 'usuariodep6s';
create user 'usuariodep7'@'localhost' identified by 'usuariodep7s';
create user 'usuariodep8'@'localhost' identified by 'usuariodep8s';
create user 'usuariodep9'@'localhost' identified by 'usuariodep9s';


-- FIM QUESTÃO 6

-- INCIO QUESTÃO 7
select * from vw_marketing;
create view vw_marketing as 
	select depnome Departamento, 
			   funnome Nome, 
               funsexo Sexo, 
               funsalario Salário, 
               estdescricao 'Estado Civil',
				case
					when fundtdem is null then 'Trabalhando'
					else concat('Demitido em: ', fundtdem)
				end as Situação
	from departamento 
	join funcionario on fundepnum = depnum
	join estadocivil on estcodigo = funestcodigo 
	where depnum = 'd001';
    
create view vw_finance as 
	select depnome Departamento, 
			   funnome Nome, 
               funsexo Sexo, 
               funsalario Salário, 
               estdescricao 'Estado Civil',
				case
					when fundtdem is null then 'Trabalhando'
					else concat('Demitido em: ', fundtdem)
				end as Situação
	from departamento 
	join funcionario on fundepnum = depnum
	join estadocivil on estcodigo = funestcodigo 
	where depnum = 'd002';

create view vw_humanresources as 
	select depnome Departamento, 
			   funnome Nome, 
               funsexo Sexo, 
               funsalario Salário, 
               estdescricao 'Estado Civil',
				case
					when fundtdem is null then 'Trabalhando'
					else concat('Demitido em: ', fundtdem)
				end as Situação
	from departamento 
	join funcionario on fundepnum = depnum
	join estadocivil on estcodigo = funestcodigo 
	where depnum = 'd003';
    
    create view vw_production as 
	select depnome Departamento, 
			   funnome Nome, 
               funsexo Sexo, 
               funsalario Salário, 
               estdescricao 'Estado Civil',
				case
					when fundtdem is null then 'Trabalhando'
					else concat('Demitido em: ', fundtdem)
				end as Situação
	from departamento 
	join funcionario on fundepnum = depnum
	join estadocivil on estcodigo = funestcodigo 
	where depnum = 'd004';
    
create view vw_development as 
	select depnome Departamento, 
			   funnome Nome, 
               funsexo Sexo, 
               funsalario Salário, 
               estdescricao 'Estado Civil',
				case
					when fundtdem is null then 'Trabalhando'
					else concat('Demitido em: ', fundtdem)
				end as Situação
	from departamento 
	join funcionario on fundepnum = depnum
	join estadocivil on estcodigo = funestcodigo 
	where depnum = 'd005';
    
    create view vw_qualitymanagement as 
	select depnome Departamento, 
			   funnome Nome, 
               funsexo Sexo, 
               funsalario Salário, 
               estdescricao 'Estado Civil',
				case
					when fundtdem is null then 'Trabalhando'
					else concat('Demitido em: ', fundtdem)
				end as Situação
	from departamento 
	join funcionario on fundepnum = depnum
	join estadocivil on estcodigo = funestcodigo 
	where depnum = 'd006';
    
    create view vw_sales as 
	select depnome Departamento, 
			   funnome Nome, 
               funsexo Sexo, 
               funsalario Salário, 
               estdescricao 'Estado Civil',
				case
					when fundtdem is null then 'Trabalhando'
					else concat('Demitido em: ', fundtdem)
				end as Situação
	from departamento 
	join funcionario on fundepnum = depnum
	join estadocivil on estcodigo = funestcodigo 
	where depnum = 'd007';
    
    create view vw_research as 
	select depnome Departamento, 
			   funnome Nome, 
               funsexo Sexo, 
               funsalario Salário, 
               estdescricao 'Estado Civil',
				case
					when fundtdem is null then 'Trabalhando'
					else concat('Demitido em: ', fundtdem)
				end as Situação
	from departamento 
	join funcionario on fundepnum = depnum
	join estadocivil on estcodigo = funestcodigo 
	where depnum = 'd008';
    
    create view vw_customerservice as 
	select depnome Departamento, 
			   funnome Nome, 
               funsexo Sexo, 
               funsalario Salário, 
               estdescricao 'Estado Civil',
				case
					when fundtdem is null then 'Trabalhando'
					else concat('Demitido em: ', fundtdem)
				end as Situação
	from departamento 
	join funcionario on fundepnum = depnum
	join estadocivil on estcodigo = funestcodigo 
	where depnum = 'd009';
    
    select * from departamento;
    
-- FIM QUESTÃO 7

-- INICIO QUESTÃO 8

grant select on bd2024.vw_marketing to 'usuariodep1'@'localhost';
grant select on bd2024.vw_finance to 'usuariodep2'@'localhost';
grant select on bd2024.vw_humanresources to 'usuariodep3'@'localhost';
grant select on bd2024.vw_production to 'usuariodep4'@'localhost';
grant select on bd2024.vw_development to 'usuariodep5'@'localhost';
grant select on bd2024.vw_qualitymanagement to 'usuariodep6'@'localhost';
grant select on bd2024.vw_sales to 'usuariodep7'@'localhost';
grant select on bd2024.vw_research to 'usuariodep8'@'localhost';
grant select on bd2024.vw_customerservice to 'usuariodep9'@'localhost';

-- INICIO QUESTÃO 8

-- INICIO QUESTÃO 9
	-- FEITO
-- FIM QUESTÃO 9

-- INICIO QUESTÃO 10
  -- C:\Program Files\MySQL\MySQL Server 8.0\bin>mysqldump -u root -p bd2024 > D:\Programação\banco_de_dados\backupbd20245lista.sql
-- FIM QUESTÃO 10