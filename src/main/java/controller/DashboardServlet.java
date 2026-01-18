package controller;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import bean.DBUtil;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        /* ================= SESSION CHECK ================= */
        HttpSession sess = request.getSession(false);
        if (sess == null || sess.getAttribute("username") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) sess.getAttribute("role");
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
            try (PreparedStatement ps =
                    con.prepareStatement("SELECT COUNT(*) FROM admission_enquiry");
                 ResultSet rs = ps.executeQuery()) {

                if (rs.next()) total = rs.getInt(1);
            }

            /* ================= ADMISSION TYPE TOTALS ================= */
            int day = 0, res = 0, semi = 0;

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT LOWER(TRIM(admission_type)), COUNT(*) " +
                    "FROM admission_enquiry GROUP BY LOWER(TRIM(admission_type))");
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String type = rs.getString(1);
                    int cnt = rs.getInt(2);

                    if (type.contains("day")) day += cnt;
                    else if (type.contains("semi")) semi += cnt;
                    else if (type.contains("res")) res += cnt;
                }
            }

            /* ================= DASHBOARD MATRIX ================= */
            // int[] = {psDay, psRes, psSemi, enqDay, enqRes, enqSemi}
            Map<String, int[]> dashboardMatrix = new LinkedHashMap<>();

            /* ---------- PRESENT STRENGTH ---------- */
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT TRIM(class), LOWER(TRIM(category)), COUNT(*) " +
                    "FROM student_master " +
                    "WHERE (TC_Status IS NULL OR TC_Status = '') " +
                    "GROUP BY TRIM(class), LOWER(TRIM(category))");
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String cls = normalizeClass(rs.getString(1));
                    String type = rs.getString(2);
                    int cnt = rs.getInt(3);

                    int[] arr = dashboardMatrix.getOrDefault(
                            cls, new int[]{0,0,0,0,0,0});

                    if (type.contains("day")) arr[0] += cnt;
                    else if (type.contains("res") && !type.contains("semi")) arr[1] += cnt;
                    else if (type.contains("semi")) arr[2] += cnt;

                    dashboardMatrix.put(cls, arr);
                }
            }

            /* ---------- ENQUIRIES ---------- */
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT TRIM(class_of_admission), LOWER(TRIM(admission_type)), COUNT(*) " +
                    "FROM admission_enquiry " +
                    "GROUP BY TRIM(class_of_admission), LOWER(TRIM(admission_type))");
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String cls = normalizeClass(rs.getString(1));
                    String type = rs.getString(2);
                    int cnt = rs.getInt(3);

                    int[] arr = dashboardMatrix.getOrDefault(
                            cls, new int[]{0,0,0,0,0,0});

                    if (type.contains("day")) arr[3] += cnt;
                    else if (type.contains("res") && !type.contains("semi")) arr[4] += cnt;
                    else if (type.contains("semi")) arr[5] += cnt;

                    dashboardMatrix.put(cls, arr);
                }
            }

            /* ================= SEND TO JSP ================= */
            request.setAttribute("total", total);
            request.setAttribute("day", day);
            request.setAttribute("res", res);
            request.setAttribute("semi", semi);
            request.setAttribute("dashboardMatrix", dashboardMatrix);

            request.getRequestDispatcher("dashboard.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    /* ================= CLASS NORMALIZATION ================= */
    private String normalizeClass(String raw) {
        if (raw == null) return "";

        raw = raw.toLowerCase().trim();

        // remove spaces & symbols but keep structure
        String clean = raw.replaceAll("[^a-z0-9]", "");

        // PRE-PRIMARY
        if (clean.matches(".*nur.*")) return "Nursery";
        if (clean.matches(".*lkg.*")) return "LKG";
        if (clean.matches(".*ukg.*")) return "UKG";

        // EXACT numeric classes (NO contains)
        if (clean.matches("^(class)?11$")) return "Class 11";
        if (clean.equals("classx")  || clean.equals("class10") || clean.equals("10"))
            return "Class-X";
        if (clean.matches("^(class)?9$"))  return "Class 9";
        if (clean.matches("^(class)?8$"))  return "Class 8";
        if (clean.matches("^(class)?7$"))  return "Class 7";
        if (clean.matches("^(class)?6$"))  return "Class 6";
        if (clean.matches("^(class)?5$"))  return "Class 5";
        if (clean.matches("^(class)?4$"))  return "Class 4";
        if (clean.matches("^(class)?3$"))  return "Class 3";
        if (clean.matches("^(class)?2$"))  return "Class 2";
        if (clean.matches("^(class)?1$"))  return "Class 1";

        return raw; // fallback (won’t mix)
    }
}
