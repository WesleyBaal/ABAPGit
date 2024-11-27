*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0005TOP
*&---------------------------------------------------------------------*


DATA: ok_code            TYPE syucomm,
      shipment_request   TYPE zrwbfbps0002-id,
      confirmed_id       TYPE zrwbfbpt0005-confirmed_id,
      check_page         TYPE char15,
      control_screen     TYPE char15,
      control_page       TYPE char15 VALUE 'UP',
      count_page         TYPE i,
      record_count       TYPE i,
      task_data          TYPE zrwbfbps0003,
      screen_fields      TYPE zrwbfbps0006,

      confirmed_id_table TYPE TABLE OF zrwbfbpt0005-confirmed_id.
