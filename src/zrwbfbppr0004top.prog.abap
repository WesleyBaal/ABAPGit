*&---------------------------------------------------------------------*
*& Include          ZRWBFBPPR0004TOP
*&---------------------------------------------------------------------*

 DATA: ok_code         TYPE syucomm,
       control_screen  TYPE char15,
       check_item      TYPE posnr,
       check_delivery  TYPE vbeln,
       control_page    TYPE char15 VALUE 'UP',
       check_page      TYPE char15,
       check_user      TYPE char15,
       count_page      TYPE i,
       record_count    TYPE i,
       task_data       TYPE zrwbfbps0003,
       picking_task    TYPE zrwbfbpt0003-picking_task,
       screen_fields   TYPE zrwbfbps0006.
