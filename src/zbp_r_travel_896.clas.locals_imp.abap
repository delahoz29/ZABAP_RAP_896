CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF travel_status,
                 open     TYPE c LENGTH 1 VALUE 'O' , "Open
                 accepted TYPE c LENGTH 1 VALUE 'A' , "Accepted
                 rejected TYPE c LENGTH 1 VALUE 'X' , "Rejected
               END OF travel_status .
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS DeductDiscount FOR MODIFY
      IMPORTING keys FOR ACTION Travel~DeductDiscount RESULT result.

    METHODS reCaclTtoalPrice FOR MODIFY
      IMPORTING keys FOR ACTION Travel~reCaclTtoalPrice.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~calculateTotalPrice.

    METHODS setStatusToOpen FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~setStatusToOpen.

    METHODS setTravelNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelNumber.

    METHODS validateAgency FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateAgency.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDateRange FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDateRange.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF z_r_travel_896 IN LOCAL MODE
          ENTITY Travel
          FIELDS ( OverallStatus )
          WITH CORRESPONDING #( keys )
          RESULT DATA(travels)
          FAILED failed.

    result = VALUE #(  FOR travel IN travels ( %tky = travel-%tky
                                               %field-BookingFee = COND #( WHEN travel-OverallStatus = travel_status-accepted
                                                                           THEN if_abap_behv=>fc-f-read_only
                                                                           ELSE if_abap_behv=>fc-f-unrestricted  )
                                               %action-acceptTravel = COND #( WHEN travel-OverallStatus = travel_status-accepted
                                                                           THEN if_abap_behv=>fc-o-disabled
                                                                           ELSE if_abap_behv=>fc-o-enabled  )
                                               %action-rejectTravel = COND #( WHEN travel-OverallStatus = travel_status-rejected
                                                                           THEN if_abap_behv=>fc-o-disabled
                                                                           ELSE if_abap_behv=>fc-o-enabled  )
                                               %action-DeductDiscount = COND #( WHEN travel-OverallStatus = travel_status-accepted
                                                                           THEN if_abap_behv=>fc-o-disabled
                                                                           ELSE if_abap_behv=>fc-o-enabled  )

  ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD acceptTravel.
* EML - Entity Manipulation Language

    MODIFY ENTITIES OF z_r_travel_896 IN LOCAL MODE
         ENTITY Travel
         UPDATE
         FIELDS ( OverallStatus )
         WITH VALUE #( FOR ls_key IN keys ( %tky          = ls_key-%tky
                                            OverallStatus = travel_status-accepted ) ).

    READ ENTITIES OF z_r_travel_896 IN LOCAL MODE
         ENTITY Travel
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky ) ).

  ENDMETHOD.

  METHOD DeductDiscount.

    DATA travels_for_update TYPE TABLE FOR UPDATE z_r_travel_896.

    READ ENTITIES OF z_r_travel_896 IN LOCAL MODE
         ENTITY Travel
         FIELDS ( BookingFee )
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    DATA percentage TYPE decfloat16.

    LOOP AT travels INTO DATA(ls_travel).

      DATA(discount_percentage) = keys[ KEY id %tky = ls_travel-%tky ]-%param-discount_percent .
      percentage = discount_percentage / 100.
      DATA(reduced_fee) = ls_travel-BookingFee * ( 1 - percentage ).

      APPEND VALUE #( %tky = ls_travel-%tky
                      BookingFee = reduced_fee   ) TO travels_for_update.
    ENDLOOP.


    MODIFY ENTITIES OF z_r_travel_896 IN LOCAL MODE
       ENTITY Travel
       UPDATE
       FIELDS ( BookingFee )
       WITH travels_for_update.

    READ ENTITIES OF z_r_travel_896 IN LOCAL MODE
            ENTITY Travel
            FIELDS ( BookingFee )
            WITH CORRESPONDING #( keys )
            RESULT DATA(travels_with_discount).

    result = VALUE #( FOR travel IN travels_with_discount ( %tky = travel-%tky
                                                            %param = travel ) ).

  ENDMETHOD.

  METHOD reCaclTtoalPrice.
  ENDMETHOD.

  METHOD rejectTravel.

* EML - Entity Manipulation Language

    MODIFY ENTITIES OF z_r_travel_896 IN LOCAL MODE
         ENTITY Travel
         UPDATE
         FIELDS ( OverallStatus )
         WITH VALUE #( FOR ls_key IN keys ( %tky          = ls_key-%tky
                                            OverallStatus = travel_status-rejected ) ).

    READ ENTITIES OF z_r_travel_896 IN LOCAL MODE
         ENTITY Travel
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(travels).

    result = VALUE #( FOR travel IN travels ( %tky = travel-%tky ) ).

  ENDMETHOD.

  METHOD calculateTotalPrice.
  ENDMETHOD.

  METHOD setStatusToOpen.
  ENDMETHOD.

  METHOD setTravelNumber.
  ENDMETHOD.

  METHOD validateAgency.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateDateRange.
  ENDMETHOD.

ENDCLASS.
