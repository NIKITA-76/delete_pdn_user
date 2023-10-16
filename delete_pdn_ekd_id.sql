DO
$$
    DECLARE
        usr            record;
        prsn           record;
        prsdc          record;
        usrlg          record;
        database       text  = current_database();
        deleter_login  text  = current_user;
        notch          record;
        usrds          record;
    BEGIN
        FOR usr IN (SELECT *
                    FROM "user" u
                    WHERE id IN (
                        '83ae22ea-1b1d-4010-81ab-6007a7f7c9f3'
                        ))
            LOOP
                RAISE NOTICE '|user %', usr.id;


                FOR prsn IN (SELECT *
                             FROM person
                             WHERE user_id = usr.id)
                    LOOP
                        RAISE NOTICE '|  person %', prsn.id;

                        FOR prsdc IN (SELECT *
                                      FROM person_document
                                      WHERE person_id = prsn.id)
                            LOOP
                                RAISE NOTICE '|    person_document %', prsdc.id;
                                DELETE FROM person_document WHERE id = prsdc.id;
                                PERFORM dblink('dbname=postgres',
                                               FORMAT(
                                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                           'VALUES (%L, %L, %L, %L)'
                                                   , database
                                                   , 'person_document'
                                                   , row_to_json(prsdc)
                                                   , deleter_login));


                            END LOOP;

                        DELETE FROM person WHERE id = prsn.id;
                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'person'
                                           , row_to_json(prsn)
                                           , deleter_login));
                    END LOOP;

                FOR usrlg IN (SELECT *
                              FROM user_login
                              WHERE user_id = usr.id)
                    LOOP
                        RAISE NOTICE '|  user_login %', usrlg.id;

                        FOR notch IN (SELECT *
                                      FROM notification_channel
                                      WHERE user_login_id = usrlg.id)
                            LOOP
                                RAISE NOTICE '|    notification_channel %', notch.id;
                                DELETE FROM notification_channel WHERE id = notch.id;

                                PERFORM dblink('dbname=postgres',
                                               FORMAT(
                                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                           'VALUES (%L, %L, %L, %L)'
                                                   , database
                                                   , 'notification_channel'
                                                   , row_to_json(notch)
                                                   , deleter_login));
                            END LOOP;

                        DELETE FROM user_login WHERE id = usrlg.id;

                        PERFORM dblink('dbname=postgres',
                                               FORMAT(
                                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                           'VALUES (%L, %L, %L, %L)'
                                                   , database
                                                   , 'user_login'
                                                   , row_to_json(usrlg)
                                                   , deleter_login));


                    END LOOP;

                FOR usrds IN (SELECT *
                              FROM user_disable_task
                              WHERE user_id = usr.id)
                    LOOP
                        RAISE NOTICE '|  user_disable_task %', usrds.id;


                        DELETE FROM user_disable_task WHERE id = usrds.id;

                        PERFORM dblink('dbname=postgres',
                                               FORMAT(
                                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                           'VALUES (%L, %L, %L, %L)'
                                                   , database
                                                   , 'user_disable_task'
                                                   , row_to_json(usrds)
                                                   , deleter_login));
                    END LOOP;



                DELETE FROM "user" WHERE id = usr.id;

                        PERFORM dblink('dbname=postgres',
                                               FORMAT(
                                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                           'VALUES (%L, %L, %L, %L)'
                                                   , database
                                                   , 'user'
                                                   , row_to_json(usr)
                                                   , deleter_login));
            END LOOP;
    END
$$;
