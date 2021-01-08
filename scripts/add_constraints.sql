-- Constraint: rpaa

ALTER TABLE db2inst1.act DROP CONSTRAINT IF EXISTS rpaa;

ALTER TABLE db2inst1.act
    ADD CONSTRAINT rpaa FOREIGN KEY (actno)
    REFERENCES db2inst1.act (actno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

-- Constraint: rde

ALTER TABLE db2inst1.department DROP CONSTRAINT IF EXISTS rde;

ALTER TABLE db2inst1.department
    ADD CONSTRAINT rde FOREIGN KEY (mgrno)
    REFERENCES db2inst1.employee (empno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE SET NULL;


-- Constraint: rod

ALTER TABLE db2inst1.department DROP CONSTRAINT IF EXISTS rod;

ALTER TABLE db2inst1.department
    ADD CONSTRAINT rod FOREIGN KEY (admrdept)
    REFERENCES db2inst1.department (deptno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;

-- Constraint: fk_emp_photo

ALTER TABLE db2inst1.emp_photo DROP CONSTRAINT IF EXISTS fk_emp_photo;

ALTER TABLE db2inst1.emp_photo
    ADD CONSTRAINT fk_emp_photo FOREIGN KEY (empno)
    REFERENCES db2inst1.employee (empno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

-- Constraint: fk_emp_resume

ALTER TABLE db2inst1.emp_resume DROP CONSTRAINT IF EXISTS fk_emp_resume;

ALTER TABLE db2inst1.emp_resume
    ADD CONSTRAINT fk_emp_resume FOREIGN KEY (empno)
    REFERENCES db2inst1.employee (empno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

-- Constraint: red

ALTER TABLE db2inst1.employee DROP CONSTRAINT IF EXISTS red;

ALTER TABLE db2inst1.employee
    ADD CONSTRAINT red FOREIGN KEY (workdept)
    REFERENCES db2inst1.department (deptno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE SET NULL;

-- Constraint: repapa

ALTER TABLE db2inst1.empprojact DROP CONSTRAINT IF EXISTS repapa;

ALTER TABLE db2inst1.empprojact
    ADD CONSTRAINT repapa FOREIGN KEY (emstdate, actno, projno)
    REFERENCES db2inst1.projact (acstdate, actno, projno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

-- Constraint: rpap

ALTER TABLE db2inst1.projact DROP CONSTRAINT IF EXISTS rpap;

ALTER TABLE db2inst1.projact
    ADD CONSTRAINT rpap FOREIGN KEY (projno)
    REFERENCES db2inst1.project (projno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

-- Constraint: fk_project_1

ALTER TABLE db2inst1.project DROP CONSTRAINT IF EXISTS fk_project_1;

ALTER TABLE db2inst1.project
    ADD CONSTRAINT fk_project_1 FOREIGN KEY (deptno)
    REFERENCES db2inst1.department (deptno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

-- Constraint: fk_project_2

ALTER TABLE db2inst1.project DROP CONSTRAINT IF EXISTS fk_project_2;

ALTER TABLE db2inst1.project
    ADD CONSTRAINT fk_project_2 FOREIGN KEY (respemp)
    REFERENCES db2inst1.employee (empno) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE RESTRICT;

-- Constraint: fk_po_cust

ALTER TABLE db2inst1.purchaseorder DROP CONSTRAINT IF EXISTS fk_po_cust;

ALTER TABLE db2inst1.purchaseorder
    ADD CONSTRAINT fk_po_cust FOREIGN KEY (custid)
    REFERENCES db2inst1.customer (cid) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE CASCADE;




