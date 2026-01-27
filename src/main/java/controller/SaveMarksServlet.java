package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Enumeration;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import bean.DBUtil;

@WebServlet("/SaveMarksServlet")
public class SaveMarksServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {

        String examDate = request.getParameter("exam_date_hidden");

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DBUtil.getConnection();
            con.setAutoCommit(false);

            // 🔥 Single query handles INSERT + UPDATE safely
            ps = con.prepareStatement(
                "INSERT INTO student_exam_marks(enquiry_id, exam_id, marks_obtained, exam_date) " +
                "VALUES(?,?,?,?) " +
                "ON DUPLICATE KEY UPDATE marks_obtained=?"
            );

            Enumeration<String> params = request.getParameterNames();

            while (params.hasMoreElements()) {
                String param = params.nextElement();

                if (param.startsWith("marks_")) {
                    String[] parts = param.split("_");

                    int enquiryId = Integer.parseInt(parts[1]);
                    int examId = Integer.parseInt(parts[2]);
                    int marks = Integer.parseInt(request.getParameter(param));

                    ps.setInt(1, enquiryId);
                    ps.setInt(2, examId);
                    ps.setInt(3, marks);
                    ps.setString(4, examDate);
                    ps.setInt(5, marks); // for UPDATE

                    ps.addBatch();
                }
            }

            ps.executeBatch();
            con.commit();

            response.sendRedirect("enter_marks.jsp?msg=success");

        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            response.sendRedirect("enter_marks.jsp?msg=error");

        } finally {
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
