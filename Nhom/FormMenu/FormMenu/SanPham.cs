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
    public partial class SanPham : Form
    {
        string sCon = "Data Source=MAIPHUONG\\MAIPHUONG;Initial Catalog=DQNN;Integrated Security=True";
        public SanPham()
        {
            InitializeComponent();
        }
        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void Luu_Click(object sender, EventArgs e)
        {
            // Kiểm tra các trường dữ liệu
            if (string.IsNullOrWhiteSpace(txtMaSP.Text))
            {
                MessageBox.Show("Mã sản phẩm không được để trống!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtTenSP.Text))
            {
                MessageBox.Show("Tên sản phẩm không được để trống!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (string.IsNullOrWhiteSpace(decGia.Text) || !decimal.TryParse(decGia.Text, out decimal dGia) || dGia <= 0)
            {
                MessageBox.Show("Giá sản phẩm phải là số lớn hơn 0 và không được để trống!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (string.IsNullOrWhiteSpace(intSL.Text) || !int.TryParse(intSL.Text, out int dSL) || dSL < 1)
            {
                MessageBox.Show("Số lượng phải là số nguyên lớn hơn hoặc bằng 1 và không được để trống!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            if (string.IsNullOrWhiteSpace(txtMoTa.Text))
            {
                txtMoTa.Text = "Không có mô tả"; // Gán giá trị mặc định nếu mô tả để trống
            }

            // Kết nối và lưu vào cơ sở dữ liệu
            SqlConnection con = new SqlConnection(sCon);
            try
            {
                con.Open();
                string sQuery = "INSERT INTO SanPham (MaSP, TenSP, DGia, SoLuongSP, MoTa) VALUES (@MaSP, @TenSP, @Gia, @SoLuong, @MoTa)";
                SqlCommand cmd = new SqlCommand(sQuery, con);

                // Gán giá trị cho các tham số
                cmd.Parameters.AddWithValue("@MaSP", txtMaSP.Text);
                cmd.Parameters.AddWithValue("@TenSP", txtTenSP.Text);
                cmd.Parameters.AddWithValue("@Gia", dGia);
                cmd.Parameters.AddWithValue("@SoLuong", dSL);
                cmd.Parameters.AddWithValue("@MoTa", txtMoTa.Text);

                cmd.ExecuteNonQuery();
                MessageBox.Show("Đã thêm sản phẩm thành công!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình lưu sản phẩm: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                con.Close(); // Đảm bảo kết nối luôn được đóng
            }
        }


        private void QuanLySanPham_Load(object sender, EventArgs e)
        {
            SqlConnection con = new SqlConnection(sCon);
            try
            {
                con.Open();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình kết nối database ");
            }
            string sQuery = "select * from SanPham";
            SqlDataAdapter adapter = new SqlDataAdapter(sQuery, con);
            DataSet ds = new DataSet();
            adapter.Fill(ds, "SanPham");
            dataGridView1.DataSource = ds.Tables["SanPham"];
        }

        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void dataGridView1_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            // Kiểm tra xem hàng được chọn có hợp lệ không
            if (e.RowIndex >= 0 && e.RowIndex < dataGridView1.Rows.Count)
            {
                // Lấy dòng được chọn
                DataGridViewRow row = dataGridView1.Rows[e.RowIndex];

                // Gán giá trị từ các ô của DataGridView vào các TextBox
                txtMaSP.Text = row.Cells["MaSP"].Value.ToString();
                txtTenSP.Text = row.Cells["TenSP"].Value.ToString();

                // Định dạng giá trị của cột "Gia" (decimal)
                if (decimal.TryParse(row.Cells["DGia"].Value.ToString(), out decimal gia))
                {
                    decGia.Text = gia.ToString("N2"); // Hiển thị dưới dạng số thập phân có 2 chữ số sau dấu chấm
                }
                else
                {
                    decGia.Text = "0.00"; // Giá trị mặc định nếu không thể chuyển đổi
                }

                // Định dạng giá trị của cột "SoLuong" (int)
                if (int.TryParse(row.Cells["SoLuongSP"].Value.ToString(), out int soLuong))
                {
                    intSL.Text = soLuong.ToString(); // Hiển thị dưới dạng số nguyên
                }
                else
                {
                    intSL.Text = "0"; // Giá trị mặc định nếu không thể chuyển đổi
                }

                txtMoTa.Text = row.Cells["MoTa"].Value.ToString();
            }
            txtMaSP.Enabled = false;
        }


        private void Sua_Click(object sender, EventArgs e)
        {
            // Khởi tạo kết nối
            SqlConnection con = new SqlConnection(sCon);

            try
            {
                con.Open();
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình kết nối DB: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            // Lấy dữ liệu từ các TextBox
            string sMaSP = txtMaSP.Text;
            string sTenSP = txtTenSP.Text;
            int sSoLuong;
            decimal sGia;
            string sMoTa = txtMoTa.Text;

            // Kiểm tra tính hợp lệ
            if (string.IsNullOrEmpty(sMaSP) || string.IsNullOrEmpty(sTenSP))
            {
                MessageBox.Show("Vui lòng nhập đầy đủ thông tin mã sản phẩm và tên sản phẩm.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                con.Close();
                return;
            }

            // Kiểm tra giá trị số lượng
            if (!int.TryParse(intSL.Text, out sSoLuong) || sSoLuong <= 0)
            {
                MessageBox.Show("Vui lòng nhập số lượng hợp lệ (lớn hơn 0).", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                con.Close();
                return;
            }

            // Kiểm tra giá trị giá
            if (!decimal.TryParse(decGia.Text, out sGia) || sGia <= 0)
            {
                MessageBox.Show("Vui lòng nhập giá hợp lệ (lớn hơn 0).", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                con.Close();
                return;
            }



            // Kiểm tra xem sản phẩm có tồn tại không
            string checkQuery = "SELECT COUNT(*) FROM SanPham WHERE MaSP = @MaSP";
            SqlCommand checkCmd = new SqlCommand(checkQuery, con);
            checkCmd.Parameters.AddWithValue("@MaSP", sMaSP);
            int count = (int)checkCmd.ExecuteScalar();

            if (count == 0)
            {
                MessageBox.Show("Mã sản phẩm không tồn tại, không thể sửa!", "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
                con.Close();
                return;
            }

            // Nếu tồn tại, thực hiện cập nhật
            string updateQuery = @"
        UPDATE SanPham 
        SET TenSP = @TenSP, DGia = @Gia, SoLuongSP = @SoLuong, MoTa = @MoTa 
        WHERE MaSP = @MaSP";
            SqlCommand cmd = new SqlCommand(updateQuery, con);
            cmd.Parameters.AddWithValue("@MaSP", sMaSP);
            cmd.Parameters.AddWithValue("@TenSP", sTenSP);
            cmd.Parameters.AddWithValue("@Gia", sGia);
            cmd.Parameters.AddWithValue("@SoLuong", sSoLuong);
            cmd.Parameters.AddWithValue("@MoTa", sMoTa);

            try
            {
                int rowsAffected = cmd.ExecuteNonQuery();
                if (rowsAffected > 0)
                {
                    MessageBox.Show("Cập nhật sản phẩm thành công!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    QuanLySanPham_Load(sender, e); // Làm mới bảng
                }
                else
                {
                    MessageBox.Show("Không có dòng nào được cập nhật. Vui lòng kiểm tra lại!", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Xảy ra lỗi trong quá trình cập nhật: " + ex.Message, "Lỗi", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                con.Close();
            }
        }




        private void Xoa_Click(object sender, EventArgs e)
        {
            // Kiểm tra nếu có ít nhất một dòng được chọn trong DataGridView
            if (dataGridView1.SelectedRows.Count > 0)
            {
                // Lấy dòng được chọn
                DataGridViewRow selectedRow = dataGridView1.SelectedRows[0];

                // Kiểm tra nếu dòng hợp lệ (không phải tiêu đề và có dữ liệu)
                if (selectedRow.Index >= 0 && selectedRow.Cells["MaSP"].Value != null)
                {
                    // Lấy mã sản phẩm từ dòng được chọn
                    string sMaSP = selectedRow.Cells["MaSP"].Value.ToString();

                    // Hiển thị hộp thoại xác nhận
                    DialogResult dialogResult = MessageBox.Show(
                        "Bạn có chắc chắn muốn xóa sản phẩm có mã " + sMaSP + "?",
                        "Xác nhận xóa",
                        MessageBoxButtons.YesNo,
                        MessageBoxIcon.Question
                    );

                    if (dialogResult == DialogResult.Yes)
                    {
                        SqlConnection con = new SqlConnection(sCon);

                        try
                        {
                            con.Open();

                            // Câu lệnh xóa sản phẩm dựa trên mã sản phẩm
                            string deleteQuery = "DELETE FROM SanPham WHERE MaSP = @MaSP";
                            SqlCommand cmd = new SqlCommand(deleteQuery, con);
                            cmd.Parameters.AddWithValue("@MaSP", sMaSP);

                            // Thực thi câu lệnh xóa
                            int rowsAffected = cmd.ExecuteNonQuery();

                            if (rowsAffected > 0)
                            {
                                MessageBox.Show(
                                    "Sản phẩm có mã " + sMaSP + " đã được xóa thành công.",
                                    "Thông báo",
                                    MessageBoxButtons.OK,
                                    MessageBoxIcon.Information
                                );

                                // Cập nhật lại DataGridView sau khi xóa
                                QuanLySanPham_Load(sender, e); // Tải lại dữ liệu
                            }
                            else
                            {
                                MessageBox.Show(
                                    "Không tìm thấy sản phẩm với mã " + sMaSP + ".",
                                    "Thông báo",
                                    MessageBoxButtons.OK,
                                    MessageBoxIcon.Warning
                                );
                            }
                        }
                        catch (Exception ex)
                        {
                            MessageBox.Show(
                                "Xảy ra lỗi trong quá trình xóa: " + ex.Message,
                                "Lỗi",
                                MessageBoxButtons.OK,
                                MessageBoxIcon.Error
                            );
                        }
                        finally
                        {
                            con.Close();
                        }
                    }
                    else
                    {
                        // Hủy thao tác xóa
                        MessageBox.Show("Thao tác xóa đã bị hủy.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
                else
                {
                    // Nếu dòng không hợp lệ (tiêu đề hoặc dòng trống)
                    MessageBox.Show("Vui lòng chọn một sản phẩm hợp lệ để xóa.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
            }
            else
            {
                // Nếu không có dòng nào được chọn
                MessageBox.Show("Vui lòng chọn sản phẩm cần xóa.", "Thông báo", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

    }
}

