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
            try (PreparedStatement ps = con.prepareStatement("SELECT COUNT(*) FROM admission_enquiry");
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
            // Map Key: Normalized Class Name, Value: [psDay, psRes, psSemi, enqDay, enqRes, enqSemi]
            Map<String, int[]> dashboardMatrix = new LinkedHashMap<>();

            /* ---------- 1. PRESENT STUDENTS (From student_master) ---------- */
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

                    int[] arr = dashboardMatrix.getOrDefault(cls, new int[6]);

                    if (type.contains("day")) arr[0] += cnt;
                    else if (type.contains("res") && !type.contains("semi")) arr[1] += cnt;
                    else if (type.contains("semi")) arr[2] += cnt;

                    dashboardMatrix.put(cls, arr);
                }
            }

            /* ---------- 2. ENQUIRIES (From admission_enquiry) ---------- */
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT TRIM(class_of_admission), LOWER(TRIM(admission_type)), COUNT(*) " +
                    "FROM admission_enquiry " +
                    "GROUP BY TRIM(class_of_admission), LOWER(TRIM(admission_type))");
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String cls = normalizeClass(rs.getString(1));
                    String type = rs.getString(2);
                    int cnt = rs.getInt(3);

                    int[] arr = dashboardMatrix.getOrDefault(cls, new int[6]);

                    if (type.contains("day")) arr[3] += cnt;
                    else if (type.contains("res") && !type.contains("semi")) arr[4] += cnt;
                    else if (type.contains("semi")) arr[5] += cnt;

                    dashboardMatrix.put(cls, arr);
                }
            }

            /* ================= 3. CLASS CAPACITY ================= */
            // Map Key: Normalized Class Name, Value: [capDay, capRes, capTotal]
            Map<String, int[]> capacityMap = new LinkedHashMap<>();

            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT TRIM(class_name), boarders, day_scholars, total_capacity FROM class_capacity");
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    String cls = normalizeClass(rs.getString(1));
                    capacityMap.put(cls, new int[]{ rs.getInt(3), rs.getInt(2), rs.getInt(4) });
                }
            }

            /* ================= SEND TO JSP ================= */
            request.setAttribute("total", total);
            request.setAttribute("day", day);
            request.setAttribute("res", res);
            request.setAttribute("semi", semi);
            request.setAttribute("dashboardMatrix", dashboardMatrix);
            request.setAttribute("capacityMap", capacityMap);

            request.getRequestDispatcher("dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }

    /**
     * Normalizes various class name formats into a standard set of keys:
     * "Nursery", "LKG", "UKG", "Class 1" through "Class 10"
     */
    private String normalizeClass(String raw) {
        if (raw == null || raw.trim().isEmpty()) return "Unknown";

        // Remove hyphens, spaces, and special characters, then to lowercase
        String clean = raw.toLowerCase().trim().replaceAll("[^a-z0-9]", "");

        // 1. Check for Class 10 (Roman 'X' or Numeric '10')
        if (clean.equals("x") || clean.equals("10") || clean.contains("classx") || clean.contains("class10")) {
            return "Class 10";
        }

        // 2. Check for Pre-Primary
        if (clean.contains("nur") || clean.contains("pre")) return "Nursery";
        if (clean.equals("lkg")) return "LKG";
        if (clean.equals("ukg")) return "UKG";
        
        // 3. Check for Classes 1-9
        // Extract only the numbers from the string
        String digits = clean.replaceAll("[^0-9]", "");
        if (!digits.isEmpty()) {
            try {
                int classNum = Integer.parseInt(digits);
                if (classNum >= 1 && classNum <= 9) {
                    return "Class " + classNum;
                }
            } catch (NumberFormatException e) { /* ignore and return raw */ }
        }

        // Fallback: Return capitalized original if no rule matches
        return raw.substring(0, 1).toUpperCase() + raw.substring(1);
    }
}