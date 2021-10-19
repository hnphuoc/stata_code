*Hàm làm tròn các thời gian do code từ excel qua replace OutTime = round(OutTime, 1000)//replace OutTime = round(OutTime, 1) vì code làm tròn excel stata khác nhau
foreach x in NGAYGIO_DK GIO_DK NGAYGIO_KHAM GIO_KHAM NGAYGIO_CDCLS GIO_CDCLS GIOTN_CDHA NGAYGIODIEUTIET GIOKQ_CDHA GIOTN_TDCN GIOKQ_TDCN GIOTN_XN GIOKQ_XN NGAYGIO_INKQXN NGAYGIO_TOABHYT GIO_TOABHYT NGAYGIO_TOANT GIO_TOANT NGAYGIO_XUTRIKB NGAYGIO_NHANTOA NGAYGIOLANHTHUOC NGAYGIO_PSTT NGAYGIO_MOISTTPK NGAYGIO_TNSA NGAYGIO_COKQSA NGAYGIO_TNXQ NGAYGIO_THXQ {
replace `x' = round(`x', 1000)
}
*Hàm ghép ngày và giờ vào 1 biến
generate double NGAYGIO_TNCDHA = dhms( NGAYTN_CDHA ,hh( GIOTN_CDHA ),mm(GIOTN_CDHA ),ss( GIOTN_CDHA ))
format NGAYGIO_TNCDHA %tcNN/DD/CCYY_HH:MM:SS
generate double NGAYGIO_KQCDHA = dhms( NGAYKQ_CDHA ,hh( GIOKQ_CDHA ),mm(GIOKQ_CDHA ),ss( GIOKQ_CDHA ))
format NGAYGIO_KQCDHA %tcNN/DD/CCYY_HH:MM:SS
generate double NGAYGIO_TNXN = dhms( NGAYTN_XN ,hh( GIOTN_XN ),mm(GIOTN_XN ),ss( GIOTN_XN ))
format NGAYGIO_TNXN %tcNN/DD/CCYY_HH:MM:SS
generate double NGAYGIO_KQXN = dhms( NGAYKQ_XN ,hh( GIOKQ_XN ),mm(GIOKQ_XN ),ss( GIOKQ_XN ))
format NGAYGIO_KQXN %tcNN/DD/CCYY_HH:MM:SS

*Drop biến ko dùng, chỉnh tên
drop NGAYGIODIEUTIET NGAYTN_TDCN GIOTN_TDCN NGAYKQ_TDCN GIOKQ_TDCN T_TDCN DIACHI MABS CHANDOAN XUTRI LOAITK COCDHA GHICHUK moctgkham moctgcho MABSCAPDON TENBSCAPDON COXN NGAYGIO_MOISTTPK NGAYGIO_PSTT KHAM1CLS SOXN
rename MABN MABN_string
destring MABN_string, generate(MABN)


*Recode mảng
sort MABN NGAYGIO_DK
gen double NGAYGIO_TNCDHAnew = NGAYGIO_TNCDHA if NGAY_DK== NGAYTN_CDHA
format NGAYGIO_TNCDHAnew %tcNN/DD/CCYY_HH:MM:SS
gen double NGAYGIO_KQCDHAnew = NGAYGIO_KQCDHA if NGAY_DK== NGAYKQ_CDHA
format NGAYGIO_KQCDHAnew %tcNN/DD/CCYY_HH:MM:SS
egen group = group( MABN )
su group, meanonly


quietly forvalues i = 1/`r(max)' {
 gen double temp = NGAYGIO_TNCDHA if group == `i' & NGAYTN_CDHA > NGAY_DK
 egen double temp1 = max(temp) if group == `i' & NGAYTN_CDHA > NGAY_DK
 format temp temp1 %tcNN/DD/CCYY_HH:MM:SS
 gen temp4 = dofc(temp1) if group == `i' & NGAYTN_CDHA > NGAY_DK
 format temp4 %td
 replace NGAYGIO_TNCDHAnew = temp1 if group == `i' & NGAYTN_CDHA == . & NGAY_DK == temp4
 
 gen double temp2 = NGAYGIO_KQCDHA if group == `i' & NGAYKQ_CDHA > NGAY_DK
 egen double temp3 = max(temp2) if group == `i' & NGAYKQ_CDHA > NGAY_DK
 format temp2 temp3 %tcNN/DD/CCYY_HH:MM:SS
 gen temp5 = dofc(temp3) if group == `i' & NGAYKQ_CDHA > NGAY_DK
 format temp5 %td
 replace NGAYGIO_KQCDHAnew = temp3 if group == `i' & NGAYKQ_CDHA == . & NGAY_DK == temp5
 drop temp temp1 temp2 temp3 temp4 temp5
 }

*Tính lại mốc thời gian:
*Xem xét tất cả mốc trong 1 ngày
gen NGAY_TNCDHAnew = dofc(NGAYGIO_TNCDHAnew)
gen NGAY_KQCDHAnew = dofc(NGAYGIO_KQCDHAnew)
gen NGAY_THUOC = dofc(NGAYGIOLANHTHUOC)
format %td NGAY_TNCDHAnew NGAY_KQCDHAnew NGAY_THUOC

count if (NGAY_KHAM != NGAY_DK & NGAY_KHAM != .) | (NGAY_CDCLS != NGAY_DK & NGAY_CDCLS != .) | (NGAYTN_XN != NGAY_DK & NGAYTN_XN != .) | (NGAYKQ_XN != NGAY_DK & NGAYKQ_XN != .) | (NGAY_TOABHYT != NGAY_DK & NGAY_TOABHYT != .) | (NGAY_TOANT != NGAY_DK & NGAY_TOANT != .) | (NGAY_TNCDHAnew != NGAY_DK & NGAY_TNCDHAnew != .) | (NGAY_KQCDHAnew != NGAY_DK & NGAY_KQCDHAnew != .) | (NGAY_THUOC!= NGAY_DK & NGAY_THUOC != .)
gen TEST_SAME_DAY_AFTER = 0 if (NGAY_KHAM != NGAY_DK & NGAY_KHAM != .) | (NGAY_CDCLS != NGAY_DK & NGAY_CDCLS != .) | (NGAYTN_XN != NGAY_DK & NGAYTN_XN != .) | (NGAYKQ_XN != NGAY_DK & NGAYKQ_XN != .) | (NGAY_TOABHYT != NGAY_DK & NGAY_TOABHYT != .) | (NGAY_TOANT != NGAY_DK & NGAY_TOANT != .) | (NGAY_TNCDHAnew != NGAY_DK & NGAY_TNCDHAnew != .) | (NGAY_KQCDHAnew != NGAY_DK & NGAY_KQCDHAnew != .) | (NGAY_THUOC!= NGAY_DK & NGAY_THUOC != .)
replace TEST_SAME_DAY_AFTER = 1 if TEST_SAME_DAY == .
gen TEST_DIFF_DAY_BEFORE = 1 if (NGAY_KHAM != NGAY_DK & NGAY_KHAM != .) | (NGAY_CDCLS != NGAY_DK & NGAY_CDCLS != .) | (NGAYTN_XN != NGAY_DK & NGAYTN_XN != .) | (NGAYKQ_XN != NGAY_DK & NGAYKQ_XN != .) | (NGAY_TOABHYT != NGAY_DK & NGAY_TOABHYT != .) | (NGAY_TOANT != NGAY_DK & NGAY_TOANT != .) | (NGAYTN_CDHA != NGAY_DK & NGAYTN_CDHA != .) | (NGAYKQ_CDHA != NGAY_DK & NGAYKQ_CDHA != .) | (NGAY_THUOC!= NGAY_DK & NGAY_THUOC != .)
replace TEST_DIFF_DAY_BEFORE = 0 if TEST_DIFF_DAY_BEFORE == .

su group, meanonly
quietly forvalues i = 1/`r(max)' {
 gen temp = TEST_SAME_DAY_AFTER + TEST_DIFF_DAY_BEFORE if group == `i'
 egen temp1 = max(temp) if group == `i'
 replace TEST_SAME_DAY_AFTER = temp1 if group == `i'
 drop temp temp1
 }

*Phân loại CĐHA, XN

gen COCDHA =  (NGAYGIO_TNCDHAnew != . )
gen COXN = (NGAYGIO_TNXN != .)
gen donthuan = (COCDHA == 0 & COXN == 0 & COTDCN == 0)
*Tính lại thời gian siêu âm
drop T_CDHA
gen double T_CDHA = minutes(NGAYGIO_KQCDHAnew-NGAYGIO_TNCDHAnew)
replace T_CDHA = 0 if T_CDHA == .

*Tính thời gian khám (2311: ADD THEM NGAY GIO XU TRI)

//Thời gian tối đa không tính thuốc 
gen which_timekothuocmax = "" 
gen double max_khongthuoc = 0 
unab time_kothuoc : NGAYGIO_DK NGAYGIO_KHAM NGAYGIO_CDCLS NGAYGIO_TOABHYT NGAYGIO_TOANT NGAYGIO_TNXN NGAYGIO_KQXN NGAYGIO_TNCDHAnew NGAYGIO_KQCDHAnew NGAYGIO_XUTRIKB

quietly foreach k of local time_kothuoc { 
    replace which_timekothuocmax = "`k'" if `k' > max_khongthuoc & `k' != .
    replace max_khongthuoc = `k' if `k' > max_khongthuoc & `k' != .
}

format max_khongthuoc %tcNN/DD/CCYY_HH:MM:SS

//Thời gian tối đa có tính thuốc
gen which_timethuocmax = "" 
gen double max_thuoc = 0 
unab time_thuoc : NGAYGIOLANHTHUOC NGAYGIO_DK NGAYGIO_KHAM NGAYGIO_CDCLS NGAYGIO_TOABHYT NGAYGIO_TOANT NGAYGIO_TNXN NGAYGIO_KQXN NGAYGIO_TNCDHAnew NGAYGIO_KQCDHAnew NGAYGIO_XUTRIKB NGAYGIO_NHANTOA

quietly foreach t of local time_thuoc { 
    replace which_timethuocmax = "`t'" if `t' > max_thuoc & `t' != .
    replace max_thuoc = `t' if `t' > max_thuoc & `t' != .
}

format max_thuoc %tcNN/DD/CCYY_HH:MM:SS

//Thời gian tối thiểu
gen which_timemin = "" 
gen double min = max_thuoc 
unab time_thuoc : NGAYGIOLANHTHUOC NGAYGIO_DK NGAYGIO_KHAM NGAYGIO_CDCLS NGAYGIO_TOABHYT NGAYGIO_TOANT NGAYGIO_TNXN NGAYGIO_KQXN NGAYGIO_TNCDHAnew NGAYGIO_KQCDHAnew NGAYGIO_XUTRIKB NGAYGIO_NHANTOA


quietly foreach m of local time_thuoc { 
    replace which_timemin = "`m'" if `m' < min & `m' != .
    replace min = `m' if `m' < min & `m' != .
}

format min %tcNN/DD/CCYY_HH:MM:SS

//Thời gian khám không tính thuốc
gen double time_khongthuoc = minutes(max_khongthuoc - min)
//Thời gian khám có tính thuôc
gen double time_thuoc = minutes(max_thuoc - min)

//Thời gian khám từ lúc bắt đầu đến kết thúc (2311)
gen double time_kham = minutes(NGAYGIO_XUTRIKB - NGAYGIO_KHAM)

//Cho các đối tượng chỉ có 1 CĐ CLS
*Thời gian chờ siêu âm là KQ CDHA - TN CDHA???

*Thời gian chờ xét nghiệm là TN XN - TG Khám???
gen double time_waiting_1XN = minutes(NGAYGIO_TNXN - NGAYGIO_KHAM) if (COCDHA == 0 & COXN == 1 & COTDCN == 0)

*Thời gian chờ mua thuốc xong
gen double time_waiting_thuoc = minutes(NGAYGIOLANHTHUOC - max(NGAYGIO_TOABHYT,NGAYGIO_TOANT, NGAYGIO_NHANTOA))
replace time_waiting_thuoc = . if time_waiting_thuoc<0

*Tính thời gian loại bỏ thời gian chạy máy xét nghiệm
gen double time_truXN = time_thuoc - T_XETNGHIEM


gen double time_waiting_kham2 = minutes(min(NGAYGIO_TOABHYT,NGAYGIO_TOANT)-max(NGAYGIO_KQXN,NGAYGIO_INKQXN,NGAYGIO_KQCDHAnew))
replace time_waiting_kham2 = . if time_waiting_kham2 < 0
*Phân loại đối tượng khám
gen doituongkham = 1 if DOITUONG == "Dịch Vụ"
replace doituongkham = 2 if DOITUONG == "Bhyt"
replace doituongkham = 3 if DOITUONG == "Thu phí"
label define doituong 1 "Dịch Vụ" 2 "BHYT" 3 "Thu phí"
label values doituongkham doituong

*Phân loại khám thai, khám phụ
gen loaikham = 1 if TENKP == "Khám Thai" | TENKP == "Khám Thai Phòng 1 (Lầu 1)"| TENKP == "Khám Thai Phòng 2 (Lầu 1)" | TENKP == "Khám Thai Phòng 3 (Lầu 1)" | TENKP == "Khám Thai Phòng 4 (Lầu 1)" | TENKP == "Khám Thai Phòng 5 (Lầu 1)" | TENKP == "Khám Thai Phòng 6 (Lầu 1)"| TENKP == "Khám Thai Phòng 7 (Trệt)" | TENKP == "Khám Thai Bệnh Lý (P.8 Lầu 1)" | TENKP == "Khám Thai P.4 (Khu B)" | TENKP == "Khám Thai P.5 (Khu B)" | TENKP == "Khám Thai P.8 (Khu B)"| TENKP == "Khám Thai Khu B"| TENKP == "Khám Thai Phòng 7 (Lầu 3)"
replace loaikham = 2 if TENKP == "Phụ Khoa" | TENKP == "Khám Phụ Khu B" | TENKP == "Khám Phụ Phòng 2" | TENKP == "Khám Phụ Phòng 3" | TENKP == "Khám Phụ Phòng 4" | TENKP == "Khám Phụ Phòng 5" | TENKP == "Khám Phụ Phòng 6" | TENKP == "Khám Phụ P.1 (Khu B)" | TENKP == "Khám Phụ P.2 (Khu B)"| TENKP == "Khám Phụ Phòng 6 (Lầu 4)"
label define loaikham 1 "Khám thai" 2 "Khám phụ"
label values loaikham loaikham

*Tính toán
bysort doituongkham: sum T_DOIKHAM, d
bysort doituongkham: sum time_khongthuoc, d
bysort doituongkham donthuan COCDHA COXN COTDCN: sum time_khongthuoc, d


*Tạo biến tháng
gen thang = mofd( NGAY_DK)
format %tmCCYY-NN thang

*Tạo biến tuần, tuần bắt đầu vào ngày thứ 2 <chỉnh chỗ != code dow 1 là Mon day - chỉnh trừ 8 tùy, https://www.statalist.org/forums/forum/general-stata-discussion/general/1345125-gen-week-variable >
gen year = year(NGAY_DK) 
gen first_Mon = mdy(1, 1, year) 
replace first = mdy(1, 1, year) + 8 - dow(mdy(1, 1, year)) if dow(mdy(1, 1, year)) != 1 
format first %td
gen week_in_y = ceil((NGAY_DK + 1 - first)/7)
gen sweek = "tuần " + string(week_in_y) + "/" + string(year) 
gen sYear_thang = string(thang, "%tmNN/YY")


gen cothuoc = 1 if NGAY_THUOC != .
replace cothuoc = 0 if NGAY_THUOC ==.

gen buoi =1 if GIO_DK<= -1893412800000
replace buoi = 0 if buoi ==.

**************Báo cáo khám A
gen week_d=dow(NGAY_DK)

*tách mốc đăng ký - khám - xử trí
gen time_mocDK = hh(NGAYGIO_DK)
gen time_mocKHAM = hh(NGAYGIO_KHAM)
gen time_XUTRI = hh(NGAYGIO_XUTRIKB)
replace time_XUTRI = . if donthuan ==1


**************

*Vẽ biểu đồ thể hiện theo tuần tháng/năm, 1. tạo biến string tháng/năm, 2. Vẽ biểu đồ sort theo tháng


graph bar (mean) time_thuoc, over(sYear_thang, sort(thang))
graph bar (median) T_DOIKHAM , over(sYear_thang, sort(thang))
graph box T_DOIKHAM , over(sYear_thang, sort(thang))

graph bar (median) T_DOIKHAM , over(sweek, sort(NGAY_DK))
graph bar (median) T_DOIKHAM if year == 2020, over(sweek, sort(NGAY_DK))
graph bar (median) T_DOIKHAM if year == 2020, over(sYear_thang, sort(thang))

*BIẾN LẤY EXPORT CHO CHẠY DỮ LIỆU
*Chạy với file excel chạy:
MABN HOTEN NAMSINH NGAYGIO_DK NGAYGIO_KHAM NGAYGIO_TNCDHAnew NGAYGIO_KQCDHAnew NGAYGIO_TNXN NGAYGIO_KQXN NGAYGIO_TOABHYT NGAYGIO_TOANT T_DOIKHAM T_CDHA T_XETNGHIEM time_khongthuoc NGAYGIOLANHTHUOC time_thuoc time_truXN loaikham doituongkham min which_timemin max_khongthuoc max_thuoc which_timekothuocmax which_timethuocmax group sYear_thang COTDCN sweek donthuan COXN COCDHA time_waiting_1XN time_waiting_thuoc time_waiting_kham2 NGAYGIO_INKQXN week_d buoi time_mocDK NGAYGIO_XUTRIKB NGAYGIO_NHANTOA





MABN HOTEN NAMSINH NGAYGIO_DK NGAYGIO_KHAM NGAYGIO_TNCDHAnew NGAYGIO_KQCDHAnew NGAYGIO_TNXN NGAYGIO_KQXN NGAYGIO_TOABHYT NGAYGIO_TOANT T_DOIKHAM T_CDHA T_XETNGHIEM time_khongthuoc NGAYGIOLANHTHUOC time_thuoc time_truXN loaikham doituongkham min which_timemin max_khongthuoc max_thuoc which_timekothuocmax which_timethuocmax group thang week_in_y sYear_thang sweek donthuan COCDHA COXN COTDCN time_waiting_1XN time_waiting_thuoc time_waiting_kham2 NGAYGIO_INKQXN week_d buoi time_mocDK NGAYGIO_XUTRIKB NGAYGIO_NHANTOA




regress time_truXN buoi COCDHA COXN COTDCN cothuoc
gen double XN_duyet_tru_in = minutes(NGAYGIO_INKQXN - NGAYGIO_KQXN)
replace XN_duyet_tru_in = . if XN_duyet_tru_in <0 | XN_duyet_tru_in >500


graph bar (median) thoigian_chay, over( sYear_thang , sort(thang)) xsize(20) title("Thời gian từ lúc đăng ký đến khi phát toa thuốc tại kho
> a Hiếm muộn năm 2016-2020") blabel(bar, pos(outside))


 







