CLASS zrwbfbpcl_container_return DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        selected_data TYPE zrwbfbps0003-delivery_data.

    METHODS return
      CHANGING
        deliveries TYPE zrwbfbps0003-delivery_data
        item_data  TYPE zrwbfbps0003-delivery_data.

  PROTECTED SECTION.

  PRIVATE SECTION.

    DATA: deliveries    TYPE zrwbfbps0003-delivery_data,
          selected_data TYPE zrwbfbps0003-delivery_data.

ENDCLASS.



CLASS zrwbfbpcl_container_return IMPLEMENTATION.

  METHOD return.

    LOOP AT me->selected_data INTO DATA(selected).

      APPEND selected TO item_data.

      UPDATE zrwbfbpt0002 SET deleted = abap_true WHERE picking_task = selected-picking_task
                                                    AND delivery     = selected-delivery
                                                    and item         = selected-item
                                                    AND id           = selected-id
                                                    AND deleted      = abap_false.

      UPDATE zrwbfbpt0004 SET deleted = abap_true WHERE picking_task = selected-picking_task
                                                    AND version      = selected-version
                                                    AND delivery     = selected-delivery
                                                    AND item         = selected-item.

      DELETE deliveries WHERE delivery   = selected-delivery
                          AND item       = selected-item.

    ENDLOOP.

    SELECT * FROM zrwbfbpt0004 INTO TABLE @DATA(picking_check)
       FOR ALL ENTRIES IN @me->selected_data WHERE picking_task = @me->selected_data-picking_task
                                               AND version      = @me->selected_data-version
                                               AND deleted      = @abap_false.

    IF sy-subrc <> 0.

      UPDATE zrwbfbpt0003 SET deleted = abap_true WHERE picking_task = selected-picking_task
                                                    AND version      = selected-version.

    ENDIF.


    SORT item_data  BY delivery.
    SORT deliveries BY delivery item.

  ENDMETHOD.


  METHOD constructor.

    me->selected_data = selected_data.

  ENDMETHOD.

ENDCLASS.
