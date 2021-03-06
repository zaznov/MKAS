   //--------------------------------------------------!
   // ��� ����� ���������� ����������� � ��������� ��� !
   // (ram_control_unit) ��� ����� ����                !
   //--------------------------------------------------!
   //              ������ �� 2020-09-17                !
   //--------------------------------------------------!

//= ram_control_unit ========================================!
//                                                           !
// ��� �������� �� �������� ������ ��������                  !
// ��  �������� � ����  ������:                              !
//                                                           !
// control_logic -- �������������� ����� �� ������ ��������; !
// state_reg -- �������, ������ �������� �������� ��������.  !
//===========================================================!

//=========== ����������� ����� =============================
//
//          !=======================[5:0]q_out=================!
//          !                                                  !
//          !   !-control_logic--!               !-state_reg-! !
//          !==>!     Y=F(X)     !      wire     !    DFF    ! !
// start ------>!                ! [5:0]int_data !           ! !    ram_ce
// wr_rd ------>![8:0]x   [5:0]y !==============>!d_in  q_out!=!==> done
// adr_limit -->!                !               !           !      inc_ram_adr
//              !                ! !------------>!clk_in     !      wr_err_reg
//              !                ! ! !---------->!clr_in     !
//              !----------------! ! !           !-----------!
// sys_clk ------------------------! !
// all_clear ------------------------!

//===========================================================

module ram_control_unit
    (
    start, wr_rd, adr_limit, all_clear, sys_clk,
    ram_ce, done, inc_ram_adr, wr_err_reg
    );
    input   start;      // ����
    input   wr_rd;      // ������/������
    input   adr_limit;  // ��� ������ ����������
    input   all_clear;  // ��������� �����
    input   sys_clk;    // ����� �������� �����
    
    output  ram_ce;         // ������� ���
    output  done;           // ����� �������� "������"
    output  inc_ram_adr;    // �=�+1 (�� ������� ������ ���)
    output  wr_err_reg;     // ������ � ������� ������


////================================!
//// ������������� �������� ������� !
////================================!
    wire    [5:0] int_data;   // ����� control_logic � ������� state_reg
    wire    [5:0] st_reg_out; // ����� state_reg � ������� control_logic


//----------------------------------------------------------------!
// ����������� �������������� ����� �� ������ �������� ���������. !
//----------------------------------------------------------------!
// !------------!        !----------!
// ! ��� �����- !        !   ���    !
// !  �������   !        ! �������� !
// !  ������    !        !  ������  !
// !------------!        !----------!
//      !                     !
//     \!/                   \!/
//      !                     !
    my_control_logic    control_logic
    (

// !-------------!       !--------!
// !   ������    !       !������  !
// ! ������������!       !��������!
// ! ������      !       !������  !
// !-------------!       !--------!
//   !          _____________!
//   !         !
//  \!/       \!/
//   !         !
    .x      ({start, wr_rd, adr_limit,st_reg_out}),
    .y      (int_data)
    );

    //--------------------------------!
    // ����������� �������� ��������� !
    //--------------------------------!
    my_state_reg    state_reg
    (
     .d_in      (int_data),
     .clk_in    (sys_clk),
     .clr_in    (all_clear),
     .q_out     (st_reg_out)
     );
     
    //---------------------!
    // ������ �����������  !
    //---------------------!
    assign  ram_ce       = (st_reg_out[5]); 
    assign  done         = (st_reg_out[4]);
    assign  inc_ram_adr  = (st_reg_out[3]);
    assign  wr_err_reg   = (st_reg_out[2]);
endmodule


//==============================!
// �������� �������� �������    !
// ��� ������������� � �������  !
//==============================!

//-my_control_logic--------------------------!
// �������������� ����� �� ������            !
// �������� ���������.                       !
// y = F(���. �����, ������ ��������).       !
// �.�. ���������� ����������� ���������     !
// ����������� ��� ������� �� �����������    !
// ������  � �� �������� ���������,          !
// ������������� �������� �������� ��������� !
//-------------------------------------------!

module my_control_logic(x, y);
    // �����
    input       [8:0] x; // ���. ����� + ��� ������ state_reg
    // ������
    output reg	[5:0] y; // ������ state_reg[5:2]
    // ��� ������ �����������.
    // ������� ����� ��� �������������� ������� [1] � [0] ���  ��������
    // ��������� state_reg ��� ���������� �������� �������� ����������� � ���
    // ����������� ������������ ��������� ����� �����������
    
    parameter idle  = 6'b100000;
    parameter w1    = 6'b000001;
    parameter w2    = 6'b100001;
    parameter w3_1  = 6'b110001;
    parameter w3_2  = 6'b101001;
    parameter r1    = 6'b000010;
    parameter r2    = 6'b000110;
    parameter r3    = 6'b100010;
    parameter r4_1  = 6'b110010;
    parameter r4_2  = 6'b101010;

    always@ (x)

// ****** ������� ��������� *********************************************
begin
//          !-------------------!  !----------!  !-------------!  !----------!
//          ! ����� ����� - ��� !  !  ������  !  !  ���������  !  ! �����    !
//          !   ���. ����� �    !  !  �����   !  !  ���������  !  ! �������� !
//          ! ������� ��������� !  !          !  !             !  !          !
//          !-------------------!  !----------!  !-------------!  !----------!
         if (x == {3'b000, idle})   y = idle;   // idle -> idle     (1)
    else if (x == {3'b001, idle})   y = idle;   // idle -> idle     (1)
    else if (x == {3'b010, idle})   y = idle;   // idle -> idle     (1)
    else if (x == {3'b011, idle})   y = idle;   // idle -> idle     (1)
            //-----------------------------------------------------------
    else if (x == {3'b100, idle})   y = w1;     // idle -> w1       (2)
    else if (x == {3'b101, idle})   y = w1;     // idle -> w1       (2)
            //-----------------------------------------------------------
    else if (x == {3'b110, idle})   y = r1;     // idle -> r1       (3)
    else if (x == {3'b111, idle})   y = r1;     // idle -> r1       (3)
            //-----------------------------------------------------------
    else if (x == {3'b100, w1})     y = w2;     // w1   -> w2       (4)
    else if (x == {3'b101, w1})     y = w2;     // w1   -> w2       (4)
            //-----------------------------------------------------------
    else if (x == {3'b101, w2})     y = w3_1;   // w2   -> w3_1     (5)
            //-----------------------------------------------------------
    else if (x == {3'b100, w2})     y = w3_2;   // w2   -> w3-2     (6)
            //-----------------------------------------------------------
    else if (x == {3'b100, w3_1})   y = idle;   // w3-1 -> idle     (7)
    else if (x == {3'b101, w3_1})   y = idle;   // w3-1 -> idle     (7)
            //-----------------------------------------------------------
    else if (x == {3'b100, w3_2})   y = idle;   // w3-2 -> idle     (8)
    else if (x == {3'b101, w3_2})   y = idle;   // w3-2 -> idle     (8)
            //-----------------------------------------------------------
    else if (x == {3'b110, r1})     y = r2;     // r1   -> r2       (9)
    else if (x == {3'b111, r1})     y = r2;     // r1   -> r2       (9)
            //-----------------------------------------------------------
    else if (x == {3'b110, r2})     y = r3;     // r2   -> r3       (10)
    else if (x == {3'b111, r2})     y = r3;     // r2   -> r3       (10)
            //-----------------------------------------------------------
    else if (x == {3'b110, r3})     y = r4_2;   // r3 -> r4_2       (11)
            //-----------------------------------------------------------
    else if (x == {3'b111, r3})     y = r4_1;   // r3 -> r4_1       (12)
            //-----------------------------------------------------------
    else if (x == {3'b110, r4_1})  y = idle;    // r4_1 -> idle     (13)
    else if (x == {3'b111, r4_1})  y = idle;    // r4_1 -> idle     (13)
            //-----------------------------------------------------------
    else if (x == {3'b110, r4_2})  y = idle;    // r4_2 -> idle     (14)
    else if (x == {3'b111, r4_2})  y = idle;    // r4_2 -> idle     (14)
            //-----------------------------------------------------------
    else                           y = idle;    // �� ������ ������.
            //-----------------------------------------------------------
//****** ����� ������� ��������� ****************************************

end
endmodule


//-my_state_reg------------------------!
// ������� ���������. ��� ������ [5:2] !
// �������� �������� �����������       !
//-------------------------------------!

module my_state_reg (d_in, clk_in, clr_in, q_out);

    //�����
    input [5:0]d_in;    // ������
    input clk_in;       // ������������
    input clr_in;       // ����������� �����
    //������
    output reg [5:0]q_out; // ������

    always @ (posedge clr_in or posedge clk_in)
begin
    if (clr_in)
    q_out <= 6'b100000;//����������� �����
    else
    q_out <= d_in;	// ������ �� �������������� ������
end
endmodule

