using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace FormMenu
{
    public partial class CTKM : Form
    {
        string sCon = "Data Source=MAIPHUONG\\MAIPHUONG;Initial Catalog=DQNN;Integrated Security=True";
        public CTKM()
        {
            InitializeComponent();
        }
        private void Form1_Load(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(sCon);
            try
            {
                con.Open();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình kết nối DB!");
            }

            string sQuery = "select * from ChuongTrinhKhuyenMai";
            SqlDataAdapter adapter = new SqlDataAdapter(sQuery, con);

            DataSet ds = new DataSet();

            adapter.Fill(ds, "KhuyenMai");
            dataGridView1.DataSource = ds.Tables["KhuyenMai"];
            con.Close();

        }

        private void txtMaCT_TextChanged(object sender, EventArgs e)
        {

        }

        private void MaSP_Click(object sender, EventArgs e)
        {

        }

        private void btnThem_Click(object sender, EventArgs e)
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

            // Lấy thông tin từ các ô nhập liệu
            string sMaCT = txtMaCT.Text.Trim();
            string sTenCT = txtTenCT.Text.Trim();
            DateTime dNgayKT = dateTimePicker1.Value;
            DateTime dNgayBD = dateTimePicker2.Value;
            string sMaSP = txtMaSP.Text.Trim();
            decimal dPTram;

            // Kiểm tra nhập liệu
            if (string.IsNullOrEmpty(sMaCT) || string.IsNullOrEmpty(sTenCT) || string.IsNullOrEmpty(sMaSP))
            {
                MessageBox.Show("Vui lòng nhập đầy đủ thông tin chương trình khuyến mãi.", "Thông báo");
                con.Close();
                return;
            }

            if (!decimal.TryParse(txtPTram.Text.Trim(), out dPTram) || dPTram < 0 || dPTram > 100)
            {
                MessageBox.Show("Phần trăm giảm giá phải là số hợp lệ từ 0 đến 100.", "Thông báo");
                con.Close();
                return;
            }

            // Kiểm tra mã chương trình có bị trùng không
            string checkMaCTQuery = "SELECT COUNT(*) FROM ChuongTrinhKhuyenMai WHERE MaCT = @MaCT";
            SqlCommand checkMaCTCmd = new SqlCommand(checkMaCTQuery, con);
            checkMaCTCmd.Parameters.AddWithValue("@MaCT", sMaCT);

            try
            {
                int maCTCount = (int)checkMaCTCmd.ExecuteScalar();
                if (maCTCount > 0)
                {
                    MessageBox.Show("Mã chương trình đã tồn tại. Vui lòng nhập mã khác.", "Thông báo");
                    con.Close();
                    return;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi kiểm tra mã chương trình: " + ex.Message, "Thông báo");
                con.Close();
                return;
            }


            // Kiểm tra mã sản phẩm có tồn tại không
            string checkProductQuery = "SELECT COUNT(*) FROM SanPham WHERE MaSP = @masp";
            SqlCommand checkProductCmd = new SqlCommand(checkProductQuery, con);
            checkProductCmd.Parameters.AddWithValue("@masp", sMaSP);

            try
            {
                int productCount = (int)checkProductCmd.ExecuteScalar();
                if (productCount == 0)
                {
                    MessageBox.Show("Mã sản phẩm không tồn tại. Vui lòng kiểm tra lại.", "Thông báo");
                    con.Close();
                    return;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi kiểm tra mã sản phẩm: " + ex.Message, "Thông báo");
                con.Close();
                return;
            }
            // Kiểm tra tên chương trình có bị trùng không
            string checkTenCTQuery = "SELECT COUNT(*) FROM ChuongTrinhKhuyenMai WHERE TenCT = @TenCT";
            SqlCommand checkTenCTCmd = new SqlCommand(checkTenCTQuery, con);
            checkTenCTCmd.Parameters.AddWithValue("@TenCT", sTenCT);

            try
            {
                int tenCTCount = (int)checkTenCTCmd.ExecuteScalar();
                if (tenCTCount > 0)
                {
                    MessageBox.Show("Tên chương trình đã tồn tại. Vui lòng nhập tên khác.", "Thông báo");
                    con.Close();
                    return;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi kiểm tra tên chương trình: " + ex.Message, "Thông báo");
                con.Close();
                return;
            }

            // Kiểm tra ngày bắt đầu phải bé hơn ngày kết thúc
            if (dNgayBD > dNgayKT || dNgayBD == dNgayKT)
            {
                MessageBox.Show("Ngày bắt đầu phải bé hơn ngày kết thúc.", "Thông báo");
                con.Close();
                return;
            }

            // Kiểm tra khoảng thời gian không trùng với các chương trình khuyến mãi khác
            string checkDateQuery = @"
    SELECT COUNT(*) 
    FROM ChuongTrinhKhuyenMai 
    WHERE (NgayBD < @NgayKT AND NgayKT > @NgayBD)"; // Kiểm tra trùng khoảng thời gian
            SqlCommand checkDateCmd = new SqlCommand(checkDateQuery, con);
            checkDateCmd.Parameters.AddWithValue("@NgayBD", dNgayBD);
            checkDateCmd.Parameters.AddWithValue("@NgayKT", dNgayKT);

            try
            {
                int dateCount = (int)checkDateCmd.ExecuteScalar();
                if (dateCount > 0)
                {
                    MessageBox.Show("Khoảng thời gian này đã trùng với chương trình khuyến mãi khác. Vui lòng kiểm tra lại.", "Thông báo");
                    con.Close();
                    return;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi kiểm tra ngày: " + ex.Message, "Thông báo");
                con.Close();
                return;
            }


            // Thêm dữ liệu vào bảng ChuongTrinhKhuyenMai
            string sQuery = "INSERT INTO ChuongTrinhKhuyenMai (MaCT, TenCT, NgayKT, NgayBD, PTram, MaSP) " +
                            "VALUES (@MaCT, @TenCT, @NgayKT, @NgayBD, @PTram, @MaSP)";
            SqlCommand cmd = new SqlCommand(sQuery, con);
            cmd.Parameters.AddWithValue("@MaCT", sMaCT);
            cmd.Parameters.AddWithValue("@TenCT", sTenCT);
            cmd.Parameters.AddWithValue("@NgayKT", dNgayKT);
            cmd.Parameters.AddWithValue("@NgayBD", dNgayBD);
            cmd.Parameters.AddWithValue("@PTram", dPTram);
            cmd.Parameters.AddWithValue("@MaSP", sMaSP);

            try
            {
                cmd.ExecuteNonQuery();
                MessageBox.Show("Thêm mới thành công!", "Thông báo");
                Form1_Load(sender, e); // Tải lại dữ liệu sau khi thêm
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình thêm mới: " + ex.Message, "Thông báo");
            }
            finally
            {
                con.Close();
            }
        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            txtMaCT.Text = dataGridView1.Rows[e.RowIndex].Cells["MaCT"].Value.ToString();
            txtTenCT.Text = dataGridView1.Rows[e.RowIndex].Cells["TenCT"].Value.ToString();
            dateTimePicker1.Value = Convert.ToDateTime(dataGridView1.Rows[e.RowIndex].Cells["NgayKT"].Value);
            dateTimePicker2.Value = Convert.ToDateTime(dataGridView1.Rows[e.RowIndex].Cells["NgayBD"].Value);
            txtPTram.Text = dataGridView1.Rows[e.RowIndex].Cells["PTram"].Value.ToString();
            txtMaSP.Text = dataGridView1.Rows[e.RowIndex].Cells["MaSP"].Value.ToString();

            txtMaCT.Enabled = false;

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
                MessageBox.Show("Xảy ra lỗi trong quá trình kết nối DB");
            }

            string sMaCT = txtMaCT.Text;
            string sTenCT = txtTenCT.Text;
            DateTime dNgayKT = dateTimePicker1.Value;
            DateTime dNgayBD = dateTimePicker2.Value;
            decimal dPTram;
            // Thử chuyển đổi giá trị từ TextBox sang số thập phân
            if (decimal.TryParse(txtPTram.Text, out dPTram))
            {
                // Kiểm tra nếu giá trị nằm trong khoảng 0 đến 100
                if (dPTram >= 0 && dPTram <= 100)
                {
                    // Giá trị hợp lệ
                    MessageBox.Show("Phần trăm giảm giá hợp lệ.");

                }
                else
                {
                    // Giá trị không hợp lệ
                    MessageBox.Show("Phần trăm giảm giá phải nằm trong khoảng từ 0 đến 100.");
                    return;
                }
            }
            else
            {
                // Thông báo khi nhập liệu không phải là số
                MessageBox.Show("Vui lòng nhập một số hợp lệ.");
            }
            // Kiểm tra tên chương trình có bị trùng không
            string checkTenCTQuery = "SELECT COUNT(*) FROM ChuongTrinhKhuyenMai WHERE TenCT = @TenCT";
            SqlCommand checkTenCTCmd = new SqlCommand(checkTenCTQuery, con);
            checkTenCTCmd.Parameters.AddWithValue("@TenCT", sTenCT);

            try
            {
                int tenCTCount = (int)checkTenCTCmd.ExecuteScalar();
                if (tenCTCount > 0)
                {
                    MessageBox.Show("Tên chương trình đã tồn tại. Vui lòng nhập tên khác.", "Thông báo");
                    con.Close();
                    return;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi kiểm tra tên chương trình: " + ex.Message, "Thông báo");
                con.Close();
                return;
            }

            // Kiểm tra ngày bắt đầu và ngày kết thúc có bị trùng không
            string checkDateQuery = "SELECT COUNT(*) FROM ChuongTrinhKhuyenMai WHERE (NgayBD = @NgayBD OR NgayKT = @NgayKT)";
            SqlCommand checkDateCmd = new SqlCommand(checkDateQuery, con);
            checkDateCmd.Parameters.AddWithValue("@NgayBD", dNgayBD);
            checkDateCmd.Parameters.AddWithValue("@NgayKT", dNgayKT);

            try
            {
                int dateCount = (int)checkDateCmd.ExecuteScalar();
                if (dateCount > 0)
                {
                    MessageBox.Show("Ngày bắt đầu hoặc ngày kết thúc đã tồn tại. Vui lòng kiểm tra lại.", "Thông báo");
                    con.Close();
                    return;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Lỗi kiểm tra ngày: " + ex.Message, "Thông báo");
                con.Close();
                return;
            }
            string sMaSP = txtMaSP.Text;

            string sQuery = "UPDATE ChuongTrinhKhuyenMai SET TenCT = @TenCT, NgayKT = @NgayKT, NgayBD = @NgayBD, " +
                            "PTram = @PTram, MaSP = @MaSP WHERE MaCT = @MaCT";
            SqlCommand cmd = new SqlCommand(sQuery, con);
            cmd.Parameters.AddWithValue("@MaCT", sMaCT);
            cmd.Parameters.AddWithValue("@TenCT", sTenCT);
            cmd.Parameters.AddWithValue("@NgayKT", dNgayKT);
            cmd.Parameters.AddWithValue("@NgayBD", dNgayBD);
            cmd.Parameters.AddWithValue("@PTram", dPTram);
            cmd.Parameters.AddWithValue("@MaSP", sMaSP);

            try
            {
                cmd.ExecuteNonQuery();
                MessageBox.Show("Cập nhật thành công!");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình cập nhật");
            }

            con.Close();

        }

        private void btnXoa_Click(object sender, EventArgs e)
        {
            DialogResult ret = MessageBox.Show("Có chắc chắn xóa không?", "Thông báo", MessageBoxButtons.OKCancel);
            if (ret == DialogResult.OK)
            {
                SqlConnection con = new SqlConnection(sCon);
                try
                {
                    con.Open();
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Xảy ra lỗi trong quá trình kết nối DB");
                }

                string sMaCT = txtMaCT.Text;
                string sQuery = "delete chuongtrinhkhuyenmai where mact = @mact";
                SqlCommand cmd = new SqlCommand(sQuery, con);
                cmd.Parameters.AddWithValue("@mact", sMaCT);
                try
                {
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Xóa thành công!");
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Xảy ra lỗi trong quá trình xóa");
                }

                con.Close();
            }

        }
    }
}



