package controller;

import bean.DBUtil;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import javax.sql.rowset.CachedRowSet;
import javax.sql.rowset.RowSetProvider;

@WebServlet("/admission")
public class AdmissionEnquiryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ================= SESSION CHECK =================
        HttpSession sess = req.getSession(false);
        if (sess == null || sess.getAttribute("username") == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        String role = (String) sess.getAttribute("role");

        if (!"Global".equalsIgnoreCase(role)
                && !"Incharge".equalsIgnoreCase(role)
                && !"Admin".equalsIgnoreCase(role)) {
            resp.setContentType("text/html");
            resp.getWriter().println("<h3 style='color:red;'>Access Denied</h3>");
            return;
        }

        String action = req.getParameter("action");

        try (Connection con = DBUtil.getConnection()) {

            // ================= APPROVE =================
            if ("approve".equalsIgnoreCase(action)) {

                int id = Integer.parseInt(req.getParameter("id"));

                PreparedStatement ps = con.prepareStatement(
                        "UPDATE admission_enquiry " +
                        "SET approved='Approved' " +
                        "WHERE enquiry_id=? AND (approved IS NULL OR approved <> 'Approved')"
                );
                ps.setInt(1, id);
                ps.executeUpdate();
            }

            // ================= EDIT =================
            if ("edit".equalsIgnoreCase(action)) {

                int id = Integer.parseInt(req.getParameter("id"));

                PreparedStatement ps = con.prepareStatement(
                        "SELECT * FROM admission_enquiry WHERE enquiry_id=?");
                ps.setInt(1, id);
                ResultSet rs = ps.executeQuery();

                CachedRowSet editRow = RowSetProvider
                        .newFactory()
                        .createCachedRowSet();
                editRow.populate(rs);

                req.setAttribute("editData", editRow);
            }

            // ================= DELETE =================
            if ("delete".equalsIgnoreCase(action)) {

                int id = Integer.parseInt(req.getParameter("id"));

                PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM admission_enquiry WHERE enquiry_id=?");
                ps.setInt(1, id);
                ps.executeUpdate();
            }

            // ================= LIST =================
            Statement st = con.createStatement();
            ResultSet rs = st.executeQuery(
                    "SELECT * FROM admission_enquiry ORDER BY enquiry_id DESC");

            CachedRowSet list = RowSetProvider
                    .newFactory()
                    .createCachedRowSet();
            list.populate(rs);

            req.setAttribute("list", list);

            // ================= FORWARD =================
            req.getRequestDispatcher("admission_enquirys.jsp")
               .forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String id = req.getParameter("enquiry_id");

        try (Connection con = DBUtil.getConnection()) {

            // ================= INSERT =================
            if (id == null || id.trim().isEmpty()) {

                PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO admission_enquiry " +
                        "(student_name, gender, date_of_birth, class_of_admission, " +
                        "admission_type, father_name, father_mobile_no, " +
                        "mother_name, mother_mobile_no, place_from, segment) " +
                        "VALUES (?,?,?,?,?,?,?,?,?,?,?)"
                );

                ps.setString(1, req.getParameter("student_name"));
                ps.setString(2, req.getParameter("gender"));
                ps.setString(3, req.getParameter("date_of_birth"));
                ps.setString(4, req.getParameter("class_of_admission"));
                ps.setString(5, req.getParameter("admission_type"));
                ps.setString(6, req.getParameter("father_name"));
                ps.setString(7, req.getParameter("father_mobile_no"));
                ps.setString(8, req.getParameter("mother_name"));
                ps.setString(9, req.getParameter("mother_mobile_no"));
                ps.setString(10, req.getParameter("place_from"));
                ps.setString(11, req.getParameter("segment"));

                ps.executeUpdate();

            } else {
                // ================= UPDATE =================
                PreparedStatement ps = con.prepareStatement(
                        "UPDATE admission_enquiry SET " +
                        "student_name=?, gender=?, date_of_birth=?, " +
                        "class_of_admission=?, admission_type=?, father_name=?, " +
                        "father_mobile_no=?, mother_name=?, mother_mobile_no=?, " +
                        "place_from=?, segment=? WHERE enquiry_id=?"
                );

                ps.setString(1, req.getParameter("student_name"));
                ps.setString(2, req.getParameter("gender"));
                ps.setString(3, req.getParameter("date_of_birth"));
                ps.setString(4, req.getParameter("class_of_admission"));
                ps.setString(5, req.getParameter("admission_type"));
                ps.setString(6, req.getParameter("father_name"));
                ps.setString(7, req.getParameter("father_mobile_no"));
                ps.setString(8, req.getParameter("mother_name"));
                ps.setString(9, req.getParameter("mother_mobile_no"));
                ps.setString(10, req.getParameter("place_from"));
                ps.setString(11, req.getParameter("segment"));
                ps.setInt(12, Integer.parseInt(id));

                ps.executeUpdate();
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }

        resp.sendRedirect("admission");
    }
}
