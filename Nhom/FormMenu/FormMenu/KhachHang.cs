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
    public partial class KhachHang : Form
    {
        string sCon = "Data Source=MAIPHUONG\\MAIPHUONG;Initial Catalog=DQNN;Integrated Security=True";
        public KhachHang()
        {
            InitializeComponent();
        }

        public void label3_Click(object sender, EventArgs e)
        {

        }

        public void label2_Click(object sender, EventArgs e)
        {

        }

        public void label5_Click(object sender, EventArgs e)
        {

        }

        public void frmQLKH_Load(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(sCon);

            try
            {
                con.Open();
            }
            catch
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình kết nối DB");
            }
            string sQuery = "select* from KhachHang";
            SqlDataAdapter adapter = new SqlDataAdapter(sQuery, con);
            DataSet ds = new DataSet();

            adapter.Fill(ds, "KhachHang");
            dataGridView1.DataSource = ds.Tables["KhachHang"];
            con.Close();
        }

        public void btnThem_Click(object sender, EventArgs e)
        {
            string sMaKH = txtMaKH.Text.Trim();
            string sTenKH = txtTenKH.Text.Trim();
            string sDiaChi = txtDiaChi.Text.Trim();
            string sSDTText = txtSDT.Text.Trim();

            if (string.IsNullOrWhiteSpace(sMaKH))
            {
                MessageBox.Show("Mã khách hàng không được để trống.");
                return;
            }
            if (string.IsNullOrWhiteSpace(sTenKH))
            {
                MessageBox.Show("Tên khách hàng không được để trống.");
                return;
            }
            if (string.IsNullOrWhiteSpace(sDiaChi))
            {
                MessageBox.Show("Địa chỉ không được để trống.");
                return;
            }

            if (sSDTText.Length != 10 || !sSDTText.All(char.IsDigit))
            {
                MessageBox.Show("Số điện thoại phải là 10 chữ số.");
                return;
            }
            int sSDT = int.Parse(sSDTText);

            DateTime selectedDate = dateNSinh.Value;
            if (selectedDate > DateTime.Now)
            {
                MessageBox.Show("Ngày tháng năm sinh không được lớn hơn thời gian hiện tại.");
                return;
            }
            string sNSinh = dateNSinh.Value.ToString("yyyy-MM-dd");

            SqlConnection con = new SqlConnection(sCon);
            try
            {
                con.Open();
            }
            catch
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình kết nối DB");
                return;
            }

            string sQuery = "INSERT INTO KhachHang (MaKH, TenKH, DiaChi, SDT, NSinh) VALUES (@MaKH, @TenKH, @DiaChi, @SDT, @NSinh)";
            SqlCommand cmd = new SqlCommand(sQuery, con);
            cmd.Parameters.AddWithValue("@MaKH", sMaKH);
            cmd.Parameters.AddWithValue("@TenKH", sTenKH);
            cmd.Parameters.AddWithValue("@DiaChi", sDiaChi);
            cmd.Parameters.AddWithValue("@SDT", sSDT);
            cmd.Parameters.AddWithValue("@NSinh", sNSinh);

            try
            {
                cmd.ExecuteNonQuery();
                MessageBox.Show("Thêm mới thông tin khách hàng thành công.");
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình thêm mới: " + ex.Message);
            }
            finally
            {
                con.Close();
            }
        }

        public void btnSua_Click(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(sCon);

            string sMaKH = txtMaKH.Text.Trim();
            string sTenKH = txtTenKH.Text.Trim();
            string sDiaChi = txtDiaChi.Text.Trim();
            string sSDTText = txtSDT.Text.Trim();

            if (string.IsNullOrWhiteSpace(sMaKH))
            {
                MessageBox.Show("Mã khách hàng không được để trống.");
                return;
            }
            if (string.IsNullOrWhiteSpace(sTenKH))
            {
                MessageBox.Show("Tên khách hàng không được để trống.");
                return;
            }
            if (string.IsNullOrWhiteSpace(sDiaChi))
            {
                MessageBox.Show("Địa chỉ không được để trống.");
                return;
            }

            if (sSDTText.Length != 10 || !sSDTText.All(char.IsDigit))
            {
                MessageBox.Show("Số điện thoại phải là 10 chữ số.");
                return;
            }

            int sSDT = int.Parse(sSDTText);

            DateTime selectedDate = dateNSinh.Value;
            if (selectedDate > DateTime.Now)
            {
                MessageBox.Show("Ngày tháng năm sinh không được lớn hơn thời gian hiện tại.");
                return;
            }

            string sNSinh = dateNSinh.Value.ToString("yyyy-MM-dd");

            try
            {
                con.Open();
            }
            catch
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình kết nối DB");
                return;
            }

            string sQuery = "UPDATE KhachHang SET TenKH=@TenKH, DiaChi=@DiaChi, SDT=@SDT, NSinh=@NSinh WHERE MaKH=@MaKH";
            SqlCommand cmd = new SqlCommand(sQuery, con);
            cmd.Parameters.AddWithValue("@MaKH", sMaKH);
            cmd.Parameters.AddWithValue("@TenKH", sTenKH);
            cmd.Parameters.AddWithValue("@DiaChi", sDiaChi);
            cmd.Parameters.AddWithValue("@SDT", sSDT);
            cmd.Parameters.AddWithValue("@NSinh", sNSinh);

            try
            {
                int rowsAffected = cmd.ExecuteNonQuery();
                if (rowsAffected > 0)
                {
                    MessageBox.Show("Sửa thông tin khách hàng thành công.");
                }
                else
                {
                    MessageBox.Show("Không tìm thấy khách hàng với mã đã nhập.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình sửa: " + ex.Message);
            }
            finally
            {
                con.Close();
            }
        }

        public void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            txtMaKH.Text = dataGridView1.Rows[e.RowIndex].Cells["MaKH"].Value?.ToString() ?? string.Empty;
            txtTenKH.Text = dataGridView1.Rows[e.RowIndex].Cells["TenKH"].Value?.ToString() ?? string.Empty;
            txtDiaChi.Text = dataGridView1.Rows[e.RowIndex].Cells["DiaChi"].Value?.ToString() ?? string.Empty;
            txtSDT.Text = dataGridView1.Rows[e.RowIndex].Cells["SDT"].Value?.ToString() ?? string.Empty;
            dateNSinh.Value = dataGridView1.Rows[e.RowIndex].Cells["NSinh"].Value != null
                ? Convert.ToDateTime(dataGridView1.Rows[e.RowIndex].Cells["NSinh"].Value)
                : DateTime.Now;
        }

        public void btnXoa_Click(object sender, EventArgs e)
        {
            DialogResult ret = MessageBox.Show("Bạn có chắc chắn xóa không?", "Thông báo", MessageBoxButtons.OKCancel);
            if (ret == DialogResult.OK)
            {
                SqlConnection con = new SqlConnection(sCon);

                try
                {
                    con.Open();
                }
                catch
                {
                    MessageBox.Show("Xảy ra lỗi trong quá trình kết nối DB");
                    return;
                }
                string sMaKH = txtMaKH.Text;
                string sQuery = "delete KhachHang where MaKH=@MaKH";
                SqlCommand cmd = new SqlCommand(sQuery, con);
                cmd.Parameters.AddWithValue("@MaKH", sMaKH);
                try
                {
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Xóa thông tin khách hành thành công");
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Xảy ra lỗi trong quá trình Xóa ");
                }
                con.Close();
            }
        }
    }
}
