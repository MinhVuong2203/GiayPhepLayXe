-- === Công dân ===
CREATE TABLE CongDan (
    MaCongDan INT IDENTITY(1000,1) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL CHECK (NgaySinh >= '1900-01-01'),
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam',N'Nữ',N'Khác')),
    CCCD VARCHAR(20) UNIQUE NOT NULL,
    DiaChi NVARCHAR(255),
    SoDienThoai VARCHAR(15) UNIQUE CHECK (SoDienThoai LIKE '0%' AND LEN(SoDienThoai)=10),
    Email VARCHAR(100) UNIQUE,
    TinhTrangSucKhoe NVARCHAR(50) DEFAULT N'Khỏe mạnh',
    NgayKhamSucKhoe DATE NULL,
    GiayKhamSucKhoe VARCHAR(50) NULL,
    NgayTao DATETIME NOT NULL DEFAULT GETDATE(),
    Anh3x4 NVARCHAR(255) NULL
);

CREATE TABLE HangGiayPhep (
    MaHang VARCHAR(10) PRIMARY KEY,
    TenHang NVARCHAR(50) NOT NULL,
    MoTa NVARCHAR(255) NULL,
    DoTuoiToiThieu INT NOT NULL DEFAULT 18,
    SoCauThiLyThuyet INT NULL,
    ThoiGianThiLyThuyet INT NULL,
    DiemDatLyThuyet DECIMAL(5,2) NULL,
    DiemDatThucHanh DECIMAL(5,2) NULL
);


-- === Hồ sơ đăng ký thi ===
CREATE TABLE HoSo (
    HoSoID INT IDENTITY(1000,1) PRIMARY KEY,
    MaCongDan INT NOT NULL FOREIGN KEY REFERENCES CongDan(MaCongDan),
    MaHang VARCHAR(10) NOT NULL FOREIGN KEY REFERENCES HangGiayPhep(MaHang),
    NgayNop DATE NOT NULL DEFAULT GETDATE(),
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Đang xử lý' CHECK (TrangThai IN (N'Đang xử lý',N'Đủ điều kiện',N'Không đủ điều kiện',N'Hoàn tất')),
    TrangThaiThanhToan BIT NOT NULL DEFAULT 0,
    GhiChu NVARCHAR(255)
);

CREATE TABLE KyThi (
    KyThiID INT IDENTITY(1000,1) PRIMARY KEY,
    TenKyThi NVARCHAR(150) NOT NULL,
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NULL,
    GioBatDau TIME(0) NULL,
    DiaDiem NVARCHAR(255) NULL,
    MaHang VARCHAR(10) NOT NULL FOREIGN KEY REFERENCES HangGiayPhep(MaHang),
    SoLuongToiDa INT NULL,
    TrangThai NVARCHAR(30) DEFAULT N'Sắp diễn ra'
);


-- Bảng KẾT QUẢ (tổng hợp theo lần thi: HoSo + KyThi + LanThi)
CREATE TABLE KetQuaThi (
    KetQuaID INT IDENTITY(1,1) PRIMARY KEY,
    HoSoID INT NOT NULL FOREIGN KEY REFERENCES HoSo(HoSoID),
    KyThiID INT NOT NULL FOREIGN KEY REFERENCES KyThi(KyThiID),
    KetQuaTongHop NVARCHAR(20) NOT NULL CHECK (KetQuaTongHop IN (N'Đạt', N'Không đạt')),
    NgayKetLuan DATETIME NOT NULL DEFAULT GETDATE(),
	LanThi INT NOT NULL DEFAULT 1,
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT UQ_KetQuaThi UNIQUE (HoSoID, KyThiID, LanThi)  -- 1 bản ghi tổng hợp/mỗi lần thi
);




-- Bảng CHI TIẾT KẾT QUẢ (mỗi phần thi 1 dòng)
CREATE TABLE KetQuaChiTiet (
    ChiTietID INT IDENTITY(1,1) PRIMARY KEY,
    KetQuaID INT NOT NULL FOREIGN KEY REFERENCES KetQuaThi(KetQuaID) ON DELETE CASCADE,
    LoaiMon NVARCHAR(20) NOT NULL CHECK (LoaiMon IN (N'Lý thuyết', N'Thực hành')),
    Diem DECIMAL(5,2) NULL,
	ThoiGianBatDau DATETIME NULL,
    KetQua NVARCHAR(20) NOT NULL CHECK (KetQua IN (N'Đạt', N'Không đạt', N'Vắng')),
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT UQ_KetQuaChiTiet UNIQUE (KetQuaID, LoaiMon)  -- tránh trùng 1 môn/lần thi
);

CREATE TABLE GiayPhep (
    GiayPhepID INT IDENTITY(1,1) PRIMARY KEY,
    MaCongDan INT NOT NULL FOREIGN KEY REFERENCES CongDan(MaCongDan),
    MaHang VARCHAR(10) NOT NULL FOREIGN KEY REFERENCES HangGiayPhep(MaHang),
    SoGiayPhep VARCHAR(20) UNIQUE NOT NULL,
    NgayCap DATE NOT NULL,
    NgayHetHan DATE NULL,                 -- A1/A có thể NULL (vĩnh viễn)
	SoDiem INT DEFAULT(12),
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Còn hiệu lực' CHECK (TrangThai IN (N'Còn hiệu lực', N'Hết hạn', N'Bị thu hồi', N'Tạm giữ')),
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT UQ_GPLX_OnePerHang UNIQUE (MaCongDan, MaHang)
);


-- === Danh mục & ghi nhận vi phạm ===
CREATE TABLE LoaiViPham (
    LoaiViPhamID INT IDENTITY(1,1) PRIMARY KEY,
    TenViPham NVARCHAR(255) NOT NULL,
    DiemTru INT NOT NULL DEFAULT 0 CHECK (DiemTru BETWEEN 0 AND 12),
    MucPhatTu DECIMAL(18,2) NULL,
    MucPhatDen DECIMAL(18,2) NULL,
    MoTa NVARCHAR(500) NULL
);

CREATE TABLE ViPham (
    ViPhamID INT IDENTITY(1,1) PRIMARY KEY,
    GiayPhepID INT NOT NULL FOREIGN KEY REFERENCES GiayPhep(GiayPhepID),
    LoaiViPhamID INT NOT NULL FOREIGN KEY REFERENCES LoaiViPham(LoaiViPhamID),
    ThoiGianViPham DATETIME NOT NULL DEFAULT GETDATE(),
    DiaDiem NVARCHAR(255) NULL,
    BienKiemSoat NVARCHAR(20) NULL,
    MucPhat DECIMAL(18,2) NULL,
    TrangThai NVARCHAR(30) NOT NULL DEFAULT N'Chưa xử lý'
        CHECK (TrangThai IN (N'Chưa xử lý', N'Đã xử phạt', N'Đã nộp phạt', N'Đang khiếu nại')),
    GhiChu NVARCHAR(500) NULL
);

-- === Cán bộ / tài khoản / vai trò ===
CREATE TABLE CanBo (
    CanBoID INT IDENTITY(1,1) PRIMARY KEY,
    MaCanBo VARCHAR(20) UNIQUE NULL,
    HoTen NVARCHAR(100) NOT NULL,
    BoPhan NVARCHAR(50) NULL,      -- Hồ sơ / Sát hạch / Cấp / Vi phạm
    Email VARCHAR(120) NULL,
    DienThoai VARCHAR(15) NULL,
    TrangThai BIT NOT NULL DEFAULT 1
);

CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) UNIQUE NOT NULL
);
INSERT INTO Roles(RoleName)
VALUES (N'Admin'), (N'CanBoHoSo'), (N'CanBoSatHach'), (N'CanBoCapGPLX'), (N'CanBoXuLyViPham');

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARBINARY(64) NOT NULL,
    Salt VARBINARY(16) NOT NULL,
    RoleID INT NOT NULL FOREIGN KEY REFERENCES Roles(RoleID),
    CanBoID INT NOT NULL FOREIGN KEY REFERENCES CanBo(CanBoID),
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE()
);

INSERT INTO CongDan(HoTen, NgaySinh, GioiTinh, CCCD, DiaChi, SoDienThoai, Email, TinhTrangSucKhoe, NgayKhamSucKhoe, GiayKhamSucKhoe, NgayTao, Anh3x4)
VALUES (N'Nguyễn Văn Bình', '2002-10-20', N'Nam', '087304004321', N'An Long', '0599599876', 'binh@gmail.com' ,N'Khỏe mạnh', '2025-07-06', './src/', '2025-10-07' , './src/');


INSERT INTO HangGiayPhep(MaHang, TenHang, MoTa, DoTuoiToiThieu, SoCauThiLyThuyet, ThoiGianThiLyThuyet, DiemDatLyThuyet, DiemDatThucHanh)
VALUES ('A1', N'Hạng A1', N'Xe mô tô đến 125cc', 18, 25, 21, 80, 80),
	   ('A', N'Hạng A', N'Xe mô tô trên 125cc', 18, 25, 21, 80, 80);

INSERT INTO HoSo(MaCongDan, MaHang)
VALUES (1000, 'A1') -- Mọi thứ mặc định ngày hôm nay, trạng thái Đang xử lý, Chưa thanh toán

INSERT INTO KyThi (TenKyThi, NgayBatDau, GioBatDau, NgayKetThuc,DiaDiem, MaHang, SoLuongToiDa, TrangThai)
VALUES (N'Đợt thi A1 - 05/2025', '2025-05-20', '2025-05-20','08:00:00', N'TT Sát hạch Q.9', 'A1', 200, N'Đã kết thúc');

INSERT INTO KetQuaThi(HoSoID, KyThiID, KetQuaTongHop, NgayKetLuan, LanThi, GhiChu)
VALUES (1001, 1000, N'Không đạt', '2025-10-08', 1, N'Rớt lý thuyết');

INSERT INTO KetQuaChiTiet(KetQuaID, LoaiMon, Diem, ThoiGianBatDau, KetQua, GhiChu)
VALUES (2, N'Lý thuyết', 19, '2025-10-08', N'Không đạt', 'Rớt')



/*
 KetQuaID INT IDENTITY(1,1) PRIMARY KEY,
    HoSoID INT NOT NULL FOREIGN KEY REFERENCES HoSo(HoSoID),
    KyThiID INT NOT NULL FOREIGN KEY REFERENCES KyThi(KyThiID),
    KetQuaTongHop NVARCHAR(20) NOT NULL CHECK (KetQuaTongHop IN (N'Đạt', N'Không đạt')),
    NgayKetLuan DATETIME NOT NULL DEFAULT GETDATE(),
	LanThi INT NOT NULL DEFAULT 1,
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT UQ_KetQuaThi UNIQUE (HoSoID, KyThiID, LanThi)  -- 1 bản ghi tổng hợp/mỗi lần thi
*/
/*
 ChiTietID INT IDENTITY(1,1) PRIMARY KEY,
    KetQuaID INT NOT NULL FOREIGN KEY REFERENCES KetQuaThi(KetQuaID) ON DELETE CASCADE,
    LoaiMon NVARCHAR(20) NOT NULL CHECK (LoaiMon IN (N'Lý thuyết', N'Thực hành')),
    Diem DECIMAL(5,2) NULL,
	ThoiGianBatDau DATETIME NULL,
    KetQua NVARCHAR(20) NOT NULL CHECK (KetQua IN (N'Đạt', N'Không đạt', N'Vắng')),
    GhiChu NVARCHAR(255) NULL,
    CONSTRAINT UQ_KetQuaChiTiet UNIQUE (KetQuaID, LoaiMon)  -- tránh trùng 1 môn/lần thi
	*/


-- Chỉ mục gợi ý
CREATE INDEX IX_HoSo_CongDan ON HoSo(MaCongDan);
CREATE INDEX IX_KQMon_HoSo ON KetQuaMonThi(HoSoID);
CREATE INDEX IX_KQMon_KyThi ON KetQuaMonThi(KyThiID);
CREATE INDEX IX_GPLX_CongDan ON GiayPhep(CongDanID);
CREATE INDEX IX_ViPham_GiayPhep ON ViPham(GiayPhepID);


-- XÓA
DROP TABLE [dbo].[ViPham]
DROP TABLE [dbo].[LoaiViPham]
DROP TABLE [dbo].[GiayPhep]
DROP TABLE [dbo].[KetQuaMonThi]
DROP TABLE [dbo].[MonThi]
DROP TABLE [dbo].[HoSo]
DROP TABLE [dbo].[KyThi]
DROP TABLE [dbo].[HangGiayPhep]
DROP TABLE [dbo].[CongDan]


-- TRIGGER

