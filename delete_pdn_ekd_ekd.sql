DO
$$
    DECLARE
        database      text = current_database();
        deleter_login text = current_user;
        leer          record;
        cusn          record;
        ur            record;
        uwdiod        record;
        clusrid       record;
        cuns          record;
        pat           record;
        pdt           record;
        pcd           record;
        empl          record;



    BEGIN

        FOR empl IN (SELECT *
                     FROM employee
                     WHERE id IN ('15b14b87-b9c4-4764-b485-271e50cb624c'))
            LOOP
                FOR leer IN (SELECT * FROM legal_entity_employee_role WHERE employee_id = empl.id)
                    LOOP

                        DELETE FROM legal_entity_employee_role WHERE employee_id = empl.id;
                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'legal_entity_employee_role'
                                           , row_to_json(leer)
                                           , deleter_login));
                    END LOOP;

                FOR pcd IN (SELECT * FROM permitted_client_department WHERE employee_id = empl.id)
                    LOOP


                        DELETE FROM permitted_client_department WHERE employee_id = empl.id;
                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'permitted_client_department'
                                           , row_to_json(pcd)
                                           , deleter_login));
                    END LOOP;

                FOR uwdiod IN (SELECT *
                               FROM update_watcher_department_ids_on_documents_task
                               WHERE employee_id = empl.id)
                    LOOP


                        DELETE FROM update_watcher_department_ids_on_documents_task uwdiod WHERE uwdiod.id = empl.id;
                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'update_watcher_department_ids_on_documents_task'
                                           , row_to_json(uwdiod)
                                           , deleter_login));
                    END LOOP;

                FOR pdt IN (SELECT *
                            FROM permitted_document_type
                            WHERE employee_id = empl.id)
                    LOOP

                        DELETE FROM permitted_document_type WHERE employee_id = empl.id;
                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'permitted_document_type'
                                           , row_to_json(pdt)
                                           , deleter_login));
                    END LOOP;

                FOR pat IN (SELECT *
                            FROM permitted_application_type
                            WHERE employee_id = empl.id)
                    LOOP

                        DELETE FROM permitted_application_type WHERE employee_id = empl.id;
                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'permitted_application_type'
                                           , row_to_json(pat)
                                           , deleter_login));
                    END LOOP;


                DELETE FROM employee WHERE id = empl.id;
                PERFORM dblink('dbname=postgres',
                               FORMAT(
                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                           'VALUES (%L, %L, %L, %L)'
                                   , database
                                   , 'employee'
                                   , row_to_json(empl)
                                   , deleter_login));


                FOR clusrid IN (SELECT cl.modified_date,
                                       cl.version,
                                       cl.external_id,
                                       cl.last_modified_id,
                                       cl.id,
                                       cl.client_id,
                                       cl.user_id
                                FROM client_user AS cl
                                         LEFT JOIN employee ON employee.client_user_id = cl.id
                                WHERE employee.id = empl.id)
                    LOOP


                        FOR cuns IN (SELECT *
                                     FROM client_user_notification_setting
                                     WHERE client_user_id = clusrid.id)
                            LOOP
                                FOR cusn IN (SELECT *
                                             FROM client_user_sent_notification cn
                                             WHERE cn.notification_setting_id = cuns.id)
                                    LOOP
                                        DELETE FROM client_user_sent_notification WHERE notification_setting_id = cusn.id;
                                        PERFORM dblink('dbname=postgres',
                                                       FORMAT(
                                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                                   'VALUES (%L, %L, %L, %L)'
                                                           , database
                                                           , 'client_user_sent_notification'
                                                           , row_to_json(cusn)
                                                           , deleter_login));

                                    END LOOP;

                                DELETE FROM client_user_notification_setting WHERE id = cuns.id;
                                PERFORM dblink('dbname=postgres',
                                               FORMAT(
                                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                           'VALUES (%L, %L, %L, %L)'
                                                   , database
                                                   , 'client_user_notification_setting'
                                                   , row_to_json(cuns)
                                                   , deleter_login));

                            END LOOP;

                    END LOOP;


                DELETE FROM client_user WHERE id = clusrid.id;

                PERFORM dblink('dbname=postgres',
                               FORMAT(
                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                           'VALUES (%L, %L, %L, %L)'
                                   , database
                                   , 'client_user'
                                   , row_to_json(clusrid)
                                   , deleter_login));

                FOR ur IN (SELECT * FROM user_reference WHERE id = clusrid.user_id)
                    LOOP
                        DELETE FROM user_reference WHERE id = clusrid.user_id;

                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'user_reference'
                                           , row_to_json(ur)
                                           , deleter_login));
                    END LOOP;


            END LOOP;

    END
$$;
