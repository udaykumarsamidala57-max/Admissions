package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import bean.DBUtil;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ================= SESSION CHECK =================
        HttpSession sess = request.getSession(false);
        if (sess == null || sess.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) sess.getAttribute("role");
        String dept = (String) sess.getAttribute("department");

        if (!"Global".equalsIgnoreCase(role)
                && !"Incharge".equalsIgnoreCase(role)
                && !"Admin".equalsIgnoreCase(role)) {

            response.setContentType("text/html");
            response.getWriter().println("<h3 style='color:red;'>Access Denied</h3>");
            return;
        }

        try (Connection con = DBUtil.getConnection()) {

            /* ================= TOTAL ENQUIRIES ================= */
            int total = 0;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) FROM admission_enquiry");
                 ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    total = rs.getInt(1);
                }
            }

            /* ================= ADMISSION TYPE TOTALS ================= */
            int day = 0, res = 0, semi = 0;

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT admission_type, COUNT(*) AS total FROM admission_enquiry GROUP BY admission_type");
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String type = rs.getString("admission_type").toLowerCase();
                    int cnt = rs.getInt("total");

                    if (type.contains("day")) day = cnt;
                    else if (type.contains("semi")) semi = cnt;
                    else if (type.contains("res")) res = cnt;
                }
            }

            /* ================= CLASS + TYPE MATRIX ================= */
            Map<String, int[]> classTypeWise = new LinkedHashMap<>();
            // int[] = {day, residential, semi, total}

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT class_of_admission, admission_type, COUNT(*) AS total " +
                    "FROM admission_enquiry " +
                    "GROUP BY class_of_admission, admission_type " +
                    "ORDER BY class_of_admission");
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String cls = rs.getString("class_of_admission");
                    String type = rs.getString("admission_type").toLowerCase();
                    int cnt = rs.getInt("total");

                    int[] arr = classTypeWise.getOrDefault(cls, new int[]{0,0,0,0});

                    if (type.contains("day")) arr[0] = cnt;
                    else if (type.contains("res")) arr[1] = cnt;
                    else if (type.contains("semi")) arr[2] = cnt;

                    arr[3] = arr[0] + arr[1] + arr[2]; // total

                    classTypeWise.put(cls, arr);
                }
            }

            /* ================= SEND TO JSP ================= */
            request.setAttribute("total", total);
            request.setAttribute("day", day);
            request.setAttribute("res", res);
            request.setAttribute("semi", semi);
            request.setAttribute("classTypeWise", classTypeWise);

            request.getRequestDispatcher("dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
}
