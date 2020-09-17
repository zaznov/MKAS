//---------------------------------!
// ��� ����� �������� ������ ���   !
// (ram_data_check) ��� ����� ���� !
//---------------------------------!
//      ������ �� 2020-09-09       !
//---------------------------------!

//= ram_data_check ==============================!
//                                               !
// ��� �������� �� �������� ������ ��������      !
// �� ������� ��:                                !
//                                               !
// - my_ram_data_check - �������������� �����    !
// �� 4 �������, ����������� ����� ������������  !
// �� ������ x1_4_in � x2_4_in (2 ��.);          !
// - �������� ������;                            !
// - ram_err_reg - ������� ����� ������ ���.     !
//                                               !
//===============================================!

module  ram_data_check (x1_in, x2_in, wr_err_reg, all_clear, err_count);

    input   [7:0] x1_in;           // ��������� ������ � ���� ������ ���
    input   [7:0] x2_in;           // ������� ���� ������ ��� => ���� ��� ������, �� x1_in = x2_in
    input   wr_err_reg;            // ����� ������ � ������� ����� ������ (�� ram_control_unit)
    input   all_clear;             // ����� ����� (�� SPI)
    output  [15:0] err_count;      // ����� ����� ������� ������ (�� SPI)
    
    wire    [3:0] err_in_byte;     // ����� ������������
    wire    [3:0] n_err4_out1;     // ������ 1-� 4-� ����. ��������� ��������������� �����
    wire    [3:0] n_err4_out2;     // ������ 2-� 4-� ����. ��������� ��������������� �����



//+++++++++++++++++++++++++++++++++!
// ������������� �������� �������  !
//+++++++++++++++++++++++++++++++++!

// ������  4-� ����. ���������  8-� �������������� �����

// !------------!   !----------!
// ! ��� �����- !   !   ���    !
// !  �������   !   ! �������� !
// !  ������    !   !  ������  !
// !------------!   !----------!
//      !               !
//     \!/             \!/
//      !
    my_ram_data_check   ram_data_check_1_4  // 4-����. �������������� ����� � 1
    (
// !-------------! !--------!
// !   ������    ! !������  !
// ! ������������! !��������!
// ! ������      ! !������  !
// !-------------! !--------!
//   !          _______!
//   !         !
//  \!/       \!/
//   !         !
.x1_4_in    ({x1_in[3], x1_in[2], x1_in[1], x1_in[0]}),
.x2_4_in    (x2_in[3:0]),
.n_err4_out (n_err4_out1)
    );
      
// ������  4-� ����. ��������� 8-� �������������� �����

// !------------!   !----------!
// ! ��� �����- !   !   ���    !
// !  �������   !   ! �������� !
// !  ������    !   !  ������  !
// !------------!   !----------!
//      !               !
//     \!/             \!/
//      !               !
    my_ram_data_check   ram_data_check_2_4  // 4-����. �������������� ����� � 2
    (
// !-------------! !--------!
// ! ������      ! !������  !
// ! ������������! !��������!
// ! ������      ! !������  !
// !-------------! !--------!
//   !          _______!
//   !         !
//  \!/       \!/
//   !         !
.x1_4_in    (x1_in[7:4]),
.x2_4_in    (x2_in[7:4]),
.n_err4_out (n_err4_out2)
    );
    
// �������� ������
    assign  err_in_byte = (n_err4_out1 + n_err4_out2);

// ������� ����� ������ ���
// !------------! !----------!
// ! ��� �����- ! !   ���    !
// ! �������    ! ! �������� !
// ! ������     ! !  ������  !
// !------------! !----------!
//      !               !
//     \!/             \!/
//      !               !
    my_ram_err_reg  ram_err_reg
    (
// !-------------! !--------!
// ! ������      ! !������  !
// ! ������������! !��������!
// ! ������      ! !������  !
// !-------------! !--------!
//   !                 !
//   !                 !----!
//  \!/                    \!/
//   !                      !
    .my_err_in_byte     (err_in_byte),
    .err_reg_clk        (wr_err_reg),
    .err_reg_clr        (all_clear),
    .my_err_reg         (err_count)
    ); 
endmodule


//==============================!
// �������� �������� �������,   !
// ������������� � �������      !
//==============================!

//- my_ram_data_check ------------!
// 4-� ��������� ����� ��������   !
// ������ ���. ������� �����      !
// ������������ � ���� ���������� !
//--------------------------------!

module my_ram_data_check (x1_4_in, x2_4_in, n_err4_out);
    input       [3:0] x1_4_in;      // ����� 1
    input       [3:0] x2_4_in;      // ����� 2
    output reg  [2:0] n_err4_out;   // ����� ������������
    wire    [3:0] x1_neq_x2;        // ������ XOR

    // ��������� ������������� ��������
    assign  x1_neq_x2   = x1_4_in ^ x2_4_in;    // ������������� ������� = 1
 
    // ������� ����� ������������� ��� � 4-� �����
    // ������� � case   
    always @ (x1_neq_x2)
    begin
    case (x1_neq_x2)
        4'b0000:    n_err4_out	= 0;
        4'b0001:    n_err4_out  = 1;
        4'b0010:    n_err4_out  = 1;
        4'b0011:    n_err4_out  = 2;
        4'b0100:    n_err4_out  = 1;
        4'b0101:    n_err4_out  = 2;
        4'b0110:    n_err4_out  = 2;
        4'b0111:    n_err4_out  = 3;
        4'b1000:    n_err4_out  = 1;
        4'b1001:    n_err4_out  = 2;
        4'b1010:    n_err4_out  = 2;
        4'b1011:    n_err4_out  = 3;
        4'b1100:    n_err4_out  = 2;
        4'b1101:    n_err4_out  = 3;
        4'b1110:    n_err4_out  = 3;
        4'b1111:    n_err4_out  = 4;
        default:    n_err4_out  = 0;
    endcase
    end
endmodule
 
//====================================================  
// �� �� �����, �� ������� � if (������)
    /*always @ (*)
    begin
        if      (x1_neq_x2 == 4'b0000)  n_err4_out = 0;
        else if (x1_neq_x2 == 4'b0001)  n_err4_out = 1;
        else if (x1_neq_x2 == 4'b0010)	n_err4_out = 1;
        else if (x1_neq_x2 == 4'b0011)  n_err4_out = 2;
        else if (x1_neq_x2 == 4'b0100)	n_err4_out = 1;
        else if (x1_neq_x2 == 4'b0101)  n_err4_out = 2;
        else if (x1_neq_x2 == 4'b0110)	n_err4_out = 2;
        else if (x1_neq_x2 == 4'b0111)  n_err4_out = 3;
        else if (x1_neq_x2 == 4'b1000)	n_err4_out = 1;
        else if (x1_neq_x2 == 4'b1001)  n_err4_out = 2;
        else if (x1_neq_x2 == 4'b1010)	n_err4_out = 2;
        else if (x1_neq_x2 == 4'b1011)  n_err4_out = 3;
        else if (x1_neq_x2 == 4'b1100)	n_err4_out = 2;
        else if (x1_neq_x2 == 4'b1101)  n_err4_out = 3;
        else if (x1_neq_x2 == 4'b1110)	n_err4_out = 3;
        else if (x1_neq_x2 == 4'b1111)  n_err4_out = 4;
        else    n_err4_out = 0;
    end */
//====================================================

//- my_ram_err_reg -------------------!
// ������� ����� ������               !
// (���������� ������������� ��������)!
//------------------------------------!

module my_ram_err_reg (my_err_in_byte, err_reg_clk, err_reg_clr, my_err_reg);
    // �����
    input   [7:0] my_err_in_byte;   // ����� �� ram_data_check
    input   err_reg_clk;            // ������������
    input   err_reg_clr;            // ����������� �����
    // ������
    output reg  [15:0] my_err_reg;  // ������ ������

    always @ (posedge err_reg_clr or posedge err_reg_clk)
        begin
            if (err_reg_clr)
            begin
            my_err_reg <= 0;        //����������� �����
            end
            else
            begin
            my_err_reg <= my_err_reg + my_err_in_byte; // ������������ ������
            end
        end
endmodule