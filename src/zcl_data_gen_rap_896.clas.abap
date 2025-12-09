CLASS zcl_data_gen_rap_896 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_data_gen_rap_896 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DELETE FROM ztravel_896.
    DELETE FROM ztravel_896d.

    INSERT ztravel_896 FROM (
            SELECT FROM  /dmo/travel
            FIELDS uuid(  )   AS travel_uuid,
                travel_id            ,
                customer_id          ,
                agency_id            ,
                begin_date           ,
                end_date             ,
                booking_fee          ,
                total_price          ,
                currency_code        ,
                description          ,
                CASE status
                WHEN 'B' THEN 'A'
                WHEN 'P' THEN 'O'
                WHEN 'N' THEN 'O'
                ELSE 'X'
                END  AS overall_status,
                createdby AS local_created_by,
                createdat AS local_created_at,
                lastchangedby AS local_last_changed_by,
                lastchangedat AS local_last_changed_at
       WHERE travel_id BETWEEN 1 AND 3000
              ).

    IF sy-subrc EQ 0.
      out->write( |Travel.......{ sy-dbcnt }| ).
    ENDIF.

  ENDMETHOD.

ENDCLASS.
