DO
$$
    declare
        json_data_temp jsonb = '{}';
        json_data      jsonb = '{}';
        database       text  = current_database();
        deleter_login  text  = current_user;
        usref          record;
        nit            record;
        nisc           record;
        nisca          record;
        nisca_cr       record;
        nir            record;
        nit_cr         record;
        nrl            record;
        nisc_cr        record;
        gkst           record;
        prit           record;
    BEGIN
        for usref in (select *
                      from user_reference
                      where id IN ('83ae22ea-1b1d-4010-81ab-6007a7f7c9f3'))
            loop
                for nit in (select *
                            from nqes_issue_task
                            where user_id = usref.id)
                    loop

                        for nisc in (select *
                                     from nqes_issue_sms_confirmation
                                     where nqes_issue_task_id = nit.id)
                            loop

                                for nisca in (select *
                                              from nqes_issue_sms_confirmation_attempt
                                              where nqes_issue_sms_confirmation_id = nisc.id)
                                    loop


                                        raise notice '|     nqes_issue_sms_confirmation_attempt %', nisca.id;

                                        delete from nqes_issue_sms_confirmation_attempt where id = nisca.id;

                                        PERFORM dblink('dbname=postgres',
                                                       FORMAT(
                                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                                   'VALUES (%L, %L, %L, %L)'
                                                           , database
                                                           , 'nqes_issue_sms_confirmation_attempt'
                                                           , row_to_json(nisca)
                                                           , deleter_login)
                                                );

                                    end loop;

                                raise notice '|    nqes_issue_sms_confirmation %', nisc.id;


                                delete from nqes_issue_sms_confirmation where id = nisc.id;

                                PERFORM dblink('dbname=postgres',
                                               FORMAT(
                                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                           'VALUES (%L, %L, %L, %L)'
                                                   , database
                                                   , 'nqes_issue_sms_confirmation'
                                                   , row_to_json(nisc)
                                                   , deleter_login)
                                        );


                            end loop;


                        raise notice '|   nqes_issue_task %', nit.id;
                        delete from nqes_issue_task where id = nit.id;

                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'nqes_issue_task'
                                           , row_to_json(nit)
                                           , deleter_login)
                                );


                    end loop;


                for nit_cr in (select *
                               from nqes_issue_task
                               where creator_id = usref.id)
                    loop

                        for nrl in (select *
                                    from nqes_reissue_log
                                    where nqes_issue_task_id = nit_cr.id)
                            loop


                                raise notice '|    nqes_reissue_log %', nrl.id;
                                delete from nqes_reissue_log where id = nrl.id;

                                PERFORM dblink('dbname=postgres',
                                               FORMAT(
                                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                           'VALUES (%L, %L, %L, %L)'
                                                   , database
                                                   , 'nqes_reissue_log'
                                                   , row_to_json(nrl)
                                                   , deleter_login)
                                        );


                            end loop;

                        for nisc_cr in (select *
                                        from nqes_issue_sms_confirmation
                                        where nqes_issue_task_id = nit_cr.id)
                            loop

                                for nisca_cr in (select *
                                                 from nqes_issue_sms_confirmation_attempt
                                                 where nqes_issue_sms_confirmation_id = nisc_cr.id)
                                    loop


                                        raise notice '|     nqes_issue_sms_confirmation_attempt %', nisca_cr.id;
                                        delete from nqes_issue_sms_confirmation_attempt where id = nisca_cr.id;

                                        PERFORM dblink('dbname=postgres',
                                                       FORMAT(
                                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                                   'VALUES (%L, %L, %L, %L)'
                                                           , database
                                                           , 'nqes_issue_sms_confirmation_attempt'
                                                           , row_to_json(nisca_cr)
                                                           , deleter_login)
                                                );


                                    end loop;


                                raise notice '|    nqes_issue_sms_confirmation %', nisc_cr.id;
                                delete from nqes_issue_sms_confirmation where id = nisc_cr.id;


                                PERFORM dblink('dbname=postgres',
                                               FORMAT(
                                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                           'VALUES (%L, %L, %L, %L)'
                                                   , database
                                                   , 'nqes_issue_sms_confirmation'
                                                   , row_to_json(nisc_cr)
                                                   , deleter_login)
                                        );------------------------------------------------------------------------------

                            end loop;


                        raise notice '|   nqes_issue_task %', nit_cr.id;
                        delete from nqes_issue_task where id = nit_cr.id;

                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'nqes_issue_sms_confirmation'
                                           , row_to_json(nit_cr)
                                           , deleter_login));
                    end loop;

                for gkst in (select *
                             from gov_key_signing_task
                             where user_id = usref.id)
                    loop


                        raise notice '|  gov_key_signing_task %', gkst.id;
                        delete from gov_key_signing_task where id = gkst.id;
                        PERFORM dblink('dbname=postgres',
                                       FORMAT(
                                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                                   'VALUES (%L, %L, %L, %L)'
                                           , database
                                           , 'gov_key_signing_task'
                                           , row_to_json(gkst)
                                           , deleter_login));
                    end loop;


            end loop;

        for prit in (select *
                     from person_remote_identification_task
                     where user_id = usref.id)
            loop


                raise notice '|  person_remote_identification_task %', prit.id;
                delete from person_remote_identification_task where id = prit.id;
                PERFORM dblink('dbname=postgres',
                               FORMAT(
                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                           'VALUES (%L, %L, %L, %L)'
                                   , database
                                   , 'person_remote_identification_task'
                                   , row_to_json(prit)
                                   , deleter_login));


            end loop;


        for nir in (select *
                    from nqes_issue_request
                    where creator_id = usref.id)
            loop


                raise notice '|  nqes_issue_request %', nir.id;
                delete from nqes_issue_request where id = nir.id;
                PERFORM dblink('dbname=postgres',
                               FORMAT(
                                           'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                           'VALUES (%L, %L, %L, %L)'
                                   , database
                                   , 'nqes_issue_request'
                                   , row_to_json(nir)
                                   , deleter_login));


            end loop;

        raise notice '| user_reference %', usref.id;
        delete from user_reference where id = usref.id;
        PERFORM dblink('dbname=postgres',
                       FORMAT(
                                   'INSERT INTO supp.deleted_data_log (database, "table", data, deleter) ' ||
                                   'VALUES (%L, %L, %L, %L)'
                           , database
                           , 'user_reference'
                           , row_to_json(usref)
                           , deleter_login));

    end
$$;
