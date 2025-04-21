using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace FormMenu
{
    public partial class BanHang : Form
    {
        string sCon = "Data Source=MAIPHUONG\\MAIPHUONG;Initial Catalog=DQNN;Integrated Security=True";
        public BanHang()
        {
            InitializeComponent();
        }
        private void frmDonhang_Load(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(sCon);

            try
            {
                con.Open();
                string sQuery = @"
            SELECT 
                h.MaDH AS [Mã Đơn Hàng],
                c.MaSP AS [Mã Sản Phẩm],
                c.SoLuong AS [Số Lượng],
                c.TongTien AS [Tổng Tiền]
            FROM HoaDon h
            JOIN HoaDonChiTiet c ON h.MaDH = c.MaDH";

                SqlDataAdapter adapter = new SqlDataAdapter(sQuery, con);
                DataSet ds = new DataSet();
                adapter.Fill(ds, "DonHang");

                // Gán dữ liệu vào DataGridView
                dataGridView1.DataSource = ds.Tables["DonHang"];

                // Kiểm tra dữ liệu trong DataGridView
                foreach (DataGridViewRow row in dataGridView1.Rows)
                {
                    foreach (DataGridViewCell cell in row.Cells)
                    {
                        Console.Write(cell.Value + "\t");
                    }
                    Console.WriteLine();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message, "Thông báo");
            }
            finally
            {
                con.Close();
            }

        }


        private void btnLuu_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(sCon);

            try
            {
                con.Open();

                // Lấy dữ liệu từ TextBox
                string sMadh = txtMadh.Text.Trim();
                string sMasp = txtMasp.Text.Trim();
                int sSluong;

                // Kiểm tra đầu vào
                if (string.IsNullOrEmpty(sMadh) || string.IsNullOrEmpty(sMasp))
                {
                    MessageBox.Show("Vui lòng nhập đầy đủ thông tin.", "Thông báo");
                    return;
                }

                if (!int.TryParse(txtSluong.Text, out sSluong) || sSluong <= 0)
                {
                    MessageBox.Show("Số lượng không hợp lệ!", "Thông báo");
                    return;
                }

                // Lấy đơn giá sản phẩm từ bảng SanPham
                string getPriceQuery = "SELECT DGia FROM SanPham WHERE MaSP = @masp";
                SqlCommand getPriceCmd = new SqlCommand(getPriceQuery, con);
                getPriceCmd.Parameters.AddWithValue("@masp", sMasp);

                object priceObj = getPriceCmd.ExecuteScalar();
                if (priceObj == null)
                {
                    MessageBox.Show("Mã sản phẩm không tồn tại!", "Thông báo");
                    return;
                }

                float unitPrice = Convert.ToSingle(priceObj);
                float sTongtien = sSluong * unitPrice;

                // Cập nhật tổng tiền vào TextBox (hiển thị cho người dùng)
                txtTtien.Text = sTongtien.ToString();

                // Kiểm tra và thêm đơn hàng mới
                string checkOrderQuery = "SELECT COUNT(*) FROM HoaDon WHERE MaDH = @madh";
                SqlCommand checkOrderCmd = new SqlCommand(checkOrderQuery, con);
                checkOrderCmd.Parameters.AddWithValue("@madh", sMadh);

                if ((int)checkOrderCmd.ExecuteScalar() == 0)
                {
                    string insertOrderQuery = "INSERT INTO HoaDon (MaDH, MaNV, Ngtao, MaKH) VALUES (@madh, 'NULL', GETDATE(), 'NULL')";
                    SqlCommand insertOrderCmd = new SqlCommand(insertOrderQuery, con);
                    insertOrderCmd.Parameters.AddWithValue("@madh", sMadh);
                    insertOrderCmd.ExecuteNonQuery();
                }

                // Thêm chi tiết hóa đơn
                string insertDetailQuery = "INSERT INTO HoaDonChiTiet (MaDH, MaSP, SoLuong, TongTien) VALUES (@madh, @masp, @soluong, @tongtien)";
                SqlCommand insertDetailCmd = new SqlCommand(insertDetailQuery, con);
                insertDetailCmd.Parameters.AddWithValue("@madh", sMadh);
                insertDetailCmd.Parameters.AddWithValue("@masp", sMasp);
                insertDetailCmd.Parameters.AddWithValue("@soluong", sSluong);
                insertDetailCmd.Parameters.AddWithValue("@tongtien", sTongtien);
                insertDetailCmd.ExecuteNonQuery();

                MessageBox.Show("Thêm đơn hàng thành công!", "Thông báo");

                // Tải lại dữ liệu vào GridView
                frmDonhang_Load(sender, e);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi: " + ex.Message, "Thông báo");
            }
            finally
            {
                con.Close();
            }
        }


        private void dataGridView1_CellDoubleClick(object sender, DataGridViewCellEventArgs e)
        {
            // Kiểm tra nếu dòng được nhấp đúp là hợp lệ
            if (e.RowIndex >= 0)
            {
                // Lấy dữ liệu từ hàng được nhấp
                txtMadh.Text = dataGridView1.Rows[e.RowIndex].Cells["Mã Đơn Hàng"].Value.ToString();
                txtMasp.Text = dataGridView1.Rows[e.RowIndex].Cells["Mã Sản Phẩm"].Value.ToString();
                txtSluong.Text = dataGridView1.Rows[e.RowIndex].Cells["Số Lượng"].Value.ToString();
                txtTtien.Text = dataGridView1.Rows[e.RowIndex].Cells["Tổng Tiền"].Value.ToString();

                // Khóa các TextBox cần thiết
                txtMadh.Enabled = false;   // Mã đơn hàng không thể chỉnh sửa
                txtMasp.Enabled = true;
                txtSluong.Enabled = true;
                txtTtien.Enabled = true;
            }
        }


        private void btnSua_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(sCon);

            try
            {
                con.Open();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình kết nối DB: " + ex.Message);
                return;
            }

            string sMadh = txtMadh.Text.Trim();
            string sMasp = txtMasp.Text.Trim();
            int sSluong;
            float sTongtien;

            if (string.IsNullOrEmpty(sMadh) || string.IsNullOrEmpty(sMasp))
            {
                MessageBox.Show("Vui lòng nhập đầy đủ thông tin mã đơn hàng và mã sản phẩm.", "Thông báo");
                con.Close();
                return;
            }

            if (!int.TryParse(txtSluong.Text, out sSluong) || sSluong <= 0)
            {
                MessageBox.Show("Vui lòng nhập số lượng hợp lệ (phải lớn hơn 0).", "Thông báo");
                con.Close();
                return;
            }

            // Lấy đơn giá từ bảng SanPham
            float donGia = 0;
            string queryGetDonGia = "SELECT DGia FROM SanPham WHERE MaSP = @masp";
            SqlCommand cmdGetDonGia = new SqlCommand(queryGetDonGia, con);
            cmdGetDonGia.Parameters.AddWithValue("@masp", sMasp);

            try
            {
                object result = cmdGetDonGia.ExecuteScalar();
                if (result != null)
                {
                    donGia = Convert.ToSingle(result);
                }
                else
                {
                    MessageBox.Show("Không tìm thấy mã sản phẩm trong bảng SanPham.", "Thông báo");
                    con.Close();
                    return;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi khi lấy đơn giá: " + ex.Message, "Thông báo");
                con.Close();
                return;
            }

            sTongtien = sSluong * donGia;

            // Cập nhật dữ liệu vào bảng HoaDonChiTiet
            string updateQuery = @"
    UPDATE HoaDonChiTiet 
    SET MaSP = @masp, SoLuong = @soluong, TongTien = @tongtien 
    WHERE MaDH = @madh";
            SqlCommand cmd = new SqlCommand(updateQuery, con);
            cmd.Parameters.AddWithValue("@madh", sMadh);
            cmd.Parameters.AddWithValue("@masp", sMasp);
            cmd.Parameters.AddWithValue("@soluong", sSluong);
            cmd.Parameters.AddWithValue("@tongtien", sTongtien);

            try
            {
                int rowsAffected = cmd.ExecuteNonQuery();
                if (rowsAffected > 0)
                {
                    MessageBox.Show("Cập nhật thành công!", "Thông báo");
                    frmDonhang_Load(sender, e);
                }
                else
                {
                    MessageBox.Show("Không có thay đổi nào trong dữ liệu. Kiểm tra lại mã đơn hàng, mã sản phẩm hoặc số lượng.", "Thông báo");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình cập nhật: " + ex.Message, "Thông báo");
            }
            finally
            {
                con.Close();
            }
        }



        private void btnXoa_Click(object sender, EventArgs e)
        {
            // Kiểm tra nếu có ít nhất một dòng được chọn
            if (dataGridView1.SelectedRows.Count > 0)
            {
                // Kiểm tra nếu dòng được chọn không phải là dòng tiêu đề (header) và là một dòng dữ liệu hợp lệ
                DataGridViewRow selectedRow = dataGridView1.SelectedRows[0];
                if (selectedRow.Index >= 0 && selectedRow.Cells["Mã Đơn Hàng"].Value != null)
                {
                    // Lấy Mã Đơn Hàng từ dòng được chọn
                    string sMadh = selectedRow.Cells["Mã Đơn Hàng"].Value.ToString();

                    // Hiển thị hộp thoại xác nhận xóa
                    DialogResult dialogResult = MessageBox.Show("Bạn có chắc chắn muốn xóa đơn hàng có mã " + sMadh + "?", "Xác nhận xóa", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

                    if (dialogResult == DialogResult.Yes)
                    {
                        SqlConnection con = new SqlConnection(sCon);

                        try
                        {
                            con.Open();
                            // Xóa dữ liệu từ bảng HoaDonChiTiet
                            string deleteDetailQuery = "DELETE FROM HoaDonChiTiet WHERE MaDH = @madh";
                            SqlCommand cmdDetail = new SqlCommand(deleteDetailQuery, con);
                            cmdDetail.Parameters.AddWithValue("@madh", sMadh);
                            cmdDetail.ExecuteNonQuery();

                            // Xóa dữ liệu từ bảng HoaDon (nếu cần)
                            string deleteOrderQuery = "DELETE FROM HoaDon WHERE MaDH = @madh";
                            SqlCommand cmdOrder = new SqlCommand(deleteOrderQuery, con);
                            cmdOrder.Parameters.AddWithValue("@madh", sMadh);
                            cmdOrder.ExecuteNonQuery();

                            MessageBox.Show("Đơn hàng có mã " + sMadh + " đã được xóa thành công.", "Thông báo");
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show("Xảy ra lỗi trong quá trình xóa: " + ex.Message, "Thông báo");
                        }
                        finally
                        {
                            con.Close();
                        }

                        // Cập nhật lại DataGridView sau khi xóa
                        frmDonhang_Load(sender, e);
                    }
                    else
                    {
                        // Nếu người dùng chọn No, hủy thao tác xóa
                        MessageBox.Show("Thao tác xóa đã bị hủy.", "Thông báo");
                    }
                }
                else
                {
                    // Nếu dòng không hợp lệ (ví dụ dòng tiêu đề hoặc trống)
                    MessageBox.Show("Vui lòng chọn một đơn hàng hợp lệ để xóa.", "Thông báo");
                }
            }
            else
            {
                // Nếu không có dòng nào được chọn
                MessageBox.Show("Vui lòng chọn đơn hàng cần xóa.", "Thông báo");
            }
        }

    }
}



