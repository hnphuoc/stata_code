
foreach x in NGAYGIO_DK GIO_DK NGAYGIO_KHAM GIO_KHAM NGAYGIO_CDCLS GIO_CDCLS GIOTN_CDHA NGAYGIODIEUTIET GIOKQ_CDHA GIOTN_TDCN GIOKQ_TDCN GIOTN_XN GIOKQ_XN NGAYGIO_INKQXN NGAYGIO_TOABHYT GIO_TOABHYT NGAYGIO_TOANT GIO_TOANT NGAYGIO_XUTRIKB NGAYGIO_NHANTOA NGAYGIOLANHTHUOC NGAYGIO_PSTT NGAYGIO_MOISTTPK NGAYGIO_TNSA NGAYGIO_COKQSA NGAYGIO_TNXQ NGAYGIO_THXQ {
replace `x' = round(`x', 1000)
}

generate double NGAYGIO_TNCDHA = dhms( NGAYTN_CDHA ,hh( GIOTN_CDHA ),mm(GIOTN_CDHA ),ss( GIOTN_CDHA ))
format NGAYGIO_TNCDHA %tcNN/DD/CCYY_HH:MM:SS
generate double NGAYGIO_KQCDHA = dhms( NGAYKQ_CDHA ,hh( GIOKQ_CDHA ),mm(GIOKQ_CDHA ),ss( GIOKQ_CDHA ))
format NGAYGIO_KQCDHA %tcNN/DD/CCYY_HH:MM:SS
generate double NGAYGIO_TNXN = dhms( NGAYTN_XN ,hh( GIOTN_XN ),mm(GIOTN_XN ),ss( GIOTN_XN ))
format NGAYGIO_TNXN %tcNN/DD/CCYY_HH:MM:SS
generate double NGAYGIO_KQXN = dhms( NGAYKQ_XN ,hh( GIOKQ_XN ),mm(GIOKQ_XN ),ss( GIOKQ_XN ))
format NGAYGIO_KQXN %tcNN/DD/CCYY_HH:MM:SS
 


sort MAVAOVIEN NGAYGIO_KHAM
by MAVAOVIEN, sort: gen count_MAVV = _N
egen group = group(MAVAOVIEN)



*lọc 1 
gen knhu = 1 if TENKP == "Khám Nhũ 1" | TENKP == "Khám Nhũ 1 Bis" | TENKP == "Khám Nhũ 2" | TENKP == "Khám Nhũ Ngoại viện"
replace knhu = 0 if knhu == .
drop if knhu == . & count_MAVV == 1

*lọc 2
bysort group: egen check_nhu = max(knhu)
drop if check_nhu == 0

drop check_nhu



*group sort bỏ thay egen

sort MAVAOVIEN
by MAVAOVIEN: gen group_2lan = 1 if _n==1

*bỏ các mã 1 lần
replace group_2lan = . if count_MAVV ==1
sort count_MAVV MAVAOVIEN group_2lan NGAYGIO_KHAM
*group
replace group_2lan = sum(group_2lan)
replace group_2lan = . if missing(MAVAOVIEN) | group_2lan == 0

gen double temp = 0
format temp %tcNN/DD/CCYY_HH:MM:SS
su group_2lan, meanonly
quietly forvalues i = 1/`r(max)' {
egen double temp1 = max(NGAYGIO_KHAM) if group_2lan == `i'
format temp1 %tcNN/DD/CCYY_HH:MM:SS
replace temp = temp1 if temp1 !=.
drop temp1
 }



 
 
 
 
gen double max_time_duoisau = 0  
gen double count_temp = 0
format count_temp max_time_duoisau %tcNN/DD/CCYY_HH:MM:SS

gen which_timemax = "" 


unab time: NGAYGIO_DK NGAYGIO_KHAM NGAY_CDCLS NGAYGIO_INKQXN NGAYGIO_TOABHYT NGAYGIO_TOANT NGAYGIO_XUTRIKB NGAYGIO_NHANTOA NGAYGIOLANHTHUOC NGAYGIO_TNSA NGAYGIO_COKQSA NGAYGIO_TNXQ NGAYGIO_THXQ NGAYGIO_TNCDHA NGAYGIO_KQCDHA NGAYGIO_TNXN
quietly foreach t of local time { 

replace which_timemax = "`t'" if `t' < temp & `t' > max_time_duoisau
replace max_time_duoisau = `t' if `t' < temp & `t' > max_time_duoisau

}

drop temp
******

replace max_time_duoisau = . if max_time_duoisau == 0
******

gen double temp = 0
format temp %tcNN/DD/CCYY_HH:MM:SS

su group_2lan, meanonly
quietly forvalues i = 1/`r(max)' {
egen double temp1 = max(max_time_duoisau) if group_2lan == `i'
format temp1 %tcNN/DD/CCYY_HH:MM:SS
replace temp = temp1 if temp1 !=.
drop temp1
 }

gen double NGAYGIO_DKnew = NGAYGIO_DK
format NGAYGIO_DKnew %tcNN/DD/CCYY_HH:MM:SS
 
replace temp = . if temp == 0

 
replace NGAYGIO_DKnew = temp if count_MAVV >1 & temp < NGAYGIO_KHAM

rename NGAYGIO_DK NGAYGIO_DK_old
rename GIO_DK GIO_DK_old
rename NGAYGIO_DKnew NGAYGIO_DK


gen ngay_thu = dow(NGAY_DK)

generate GIO = hh(NGAYGIO_DK) + mm(NGAYGIO_DK)/60 + ss(NGAYGIO_DK)/3600

*Chia khung giờ
gen khunggio = 1 if GIO <7.25
replace khunggio = 2 if GIO >= 7.25 & GIO < 8
replace khunggio = 3 if GIO >= 8 & GIO < 9
replace khunggio = 4 if GIO >= 9 & GIO < 10
replace khunggio = 5 if GIO >= 10 & GIO < 11
replace khunggio = 6 if GIO >= 11 & GIO < 12
replace khunggio = 7 if GIO >= 12 & GIO < 13
replace khunggio = 8 if GIO >= 13 & GIO < 14
replace khunggio = 9 if GIO >= 14 & GIO < 15
replace khunggio = 10 if GIO >= 15 & GIO < 16
replace khunggio = 11 if GIO >= 16 & GIO != .


gen buoi =1 if GIO<= 11.75
replace buoi = 0 if buoi ==.


*Tính toán

gen T_CHO = (NGAYGIO_KHAM - NGAYGIO_DK)/60000
gen T_CHO_check = T_CHO >80
gen T_CHO_old = (NGAYGIO_KHAM - NGAYGIO_DK_old)/60000
replace T_CHO = T_CHO_old if NGAYGIO_DK_old > NGAYGIO_DK

drop if knhu == 0
*Lệnh chạy dừng...

*Phân tích
tab khunggio T_CHO_check

gen check_lech = NGAYGIO_DK_old - NGAYGIO_DK
gen check_phu_nhu = check_lech <0
tab khunggio check_phu_nhu

tab ngay_thu
tab ngay_thu buoi
bysort ngay_thu: sum T_CHO
tabulate ngay_thu buoi, summarize(T_CHO)

*o91.1

gen o911 = MAICD == "O91.1"

sort MAVAOVIEN
by MAVAOVIEN, sort: gen count_o911 = _N if o911 ==1
egen group = group(MAVAOVIEN)
