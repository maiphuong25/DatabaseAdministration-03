using System;
using System.Windows.Forms;

namespace FormMenu
{
    public partial class MDIMenu : Form
    {
        public MDIMenu()
        {
            InitializeComponent();
        }

        // Tạo Sản Phẩm
        public void taoSPToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SanPham taoSP = new SanPham();
            taoSP.MdiParent = this;
            taoSP.Show();
        }

        // Sửa Sản Phẩm
        public void suaSPToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SanPham suaSP = new SanPham();
            suaSP.MdiParent = this;
            suaSP.Show();
        }

        // Hủy (Xóa) Sản Phẩm
        public void huySPToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SanPham huySP = new SanPham();
            huySP.MdiParent = this;
            huySP.Show();
        }

        // Tạo Đơn Hàng
        public void taoDHToolStripMenuItem_Click(object sender, EventArgs e)
        {
            BanHang taoDH = new BanHang();
            taoDH.MdiParent = this;
            taoDH.Show();
        }

        // Tạo Chương Trình Khuyến Mãi (CTKM)
        public void taoCTKMToolStripMenuItem_Click(object sender, EventArgs e)
        {
            CTKM taoCTKM = new CTKM();
            taoCTKM.MdiParent = this;
            taoCTKM.Show();
        }

        // Sửa CTKM
        public void suaCTKMToolStripMenuItem_Click(object sender, EventArgs e)
        {
            CTKM suaCTKM = new CTKM();
            suaCTKM.MdiParent = this;
            suaCTKM.Show();
        }

        // Xóa CTKM
        public void xoaCTKMToolStripMenuItem_Click(object sender, EventArgs e)
        {
            CTKM xoaCTKM = new CTKM();
            xoaCTKM.MdiParent = this;
            xoaCTKM.Show();
        }

        // Tạo Thông Tin Khách Hàng
        public void taoTTKHToolStripMenuItem_Click(object sender, EventArgs e)
        {
            KhachHang taoKH = new KhachHang();
            taoKH.MdiParent = this;
            taoKH.Show();
        }

        // Sửa Thông Tin Khách Hàng
        public void suaTTKHToolStripMenuItem_Click(object sender, EventArgs e)
        {
            KhachHang suaKH = new KhachHang();
            suaKH.MdiParent = this;
            suaKH.Show();
        }

        // Xóa Thông Tin Khách Hàng
        public void xoaTTKHToolStripMenuItem_Click(object sender, EventArgs e)
        {
            KhachHang xoaKH = new KhachHang();
            xoaKH.MdiParent = this;
            xoaKH.Show();
        }

        // Xem Sản Phẩm
        public void xemSPToolStripMenuItem_Click(object sender, EventArgs e)
        {
            SanPham xemSP = new SanPham();
            xemSP.MdiParent = this;
            xemSP.Show();
        }

        private void xemDHToolStripMenuItem_Click(object sender, EventArgs e)
        {
            BanHang xemDH = new BanHang();
            xemDH.MdiParent = this;
            xemDH.Show();
        }

        private void xemTTKHToolStripMenuItem_Click(object sender, EventArgs e)
        {
            KhachHang xemKH = new KhachHang();
            xemKH.MdiParent = this;
            xemKH.Show();
        }

        private void xemCTKMToolStripMenuItem_Click(object sender, EventArgs e)
        {
            CTKM xemCTKM = new CTKM();
            xemCTKM.MdiParent = this;
            xemCTKM.Show();
        }

        private void KMToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void TTKHToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }
    }
}
