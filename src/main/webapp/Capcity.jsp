<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="bean.DBUtil" %>

<%
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    String action = request.getParameter("action");

    try {
        con = DBUtil.getConnection();

        /* DOWNLOAD */
        if ("download".equals(action)) {
            response.setContentType("application/vnd.ms-excel");
            response.setHeader("Content-Disposition",
                    "attachment; filename=class_capacity.csv");

            out.println("ID,Class,Boarders,Day Scholars,Girls,Boys,Total");

            ps = con.prepareStatement("SELECT * FROM class_capacity ORDER BY id");
            rs = ps.executeQuery();

            while (rs.next()) {
                out.println(
                        rs.getInt("id") + "," +
                        rs.getString("class_name") + "," +
                        rs.getInt("boarders") + "," +
                        rs.getInt("day_scholars") + "," +
                        rs.getString("boarders_girls") + "," +
                        rs.getString("boarders_boys") + "," +
                        rs.getInt("total_capacity")
                );
            }
            return;
        }

        /* ADD */
        if ("add".equals(action)) {
            ps = con.prepareStatement(
                "INSERT INTO class_capacity " +
                "(class_name, boarders, day_scholars, total_capacity, boarders_girls, boarders_boys) " +
                "VALUES (?, ?, ?, ?, ?, ?)");

            int boarders = Integer.parseInt(request.getParameter("boarders"));
            int dayScholars = Integer.parseInt(request.getParameter("day_scholars"));

            ps.setString(1, request.getParameter("class_name"));
            ps.setInt(2, boarders);
            ps.setInt(3, dayScholars);
            ps.setInt(4, boarders + dayScholars);
            ps.setString(5, request.getParameter("boarders_girls"));
            ps.setString(6, request.getParameter("boarders_boys"));
            ps.executeUpdate();
        }

        /* UPDATE */
        if ("update".equals(action)) {
            ps = con.prepareStatement(
                "UPDATE class_capacity SET " +
                "boarders=?, day_scholars=?, total_capacity=?, " +
                "boarders_girls=?, boarders_boys=? " +
                "WHERE id=?");

            int boarders = Integer.parseInt(request.getParameter("boarders"));
            int dayScholars = Integer.parseInt(request.getParameter("day_scholars"));

            ps.setInt(1, boarders);
            ps.setInt(2, dayScholars);
            ps.setInt(3, boarders + dayScholars);
            ps.setString(4, request.getParameter("boarders_girls"));
            ps.setString(5, request.getParameter("boarders_boys"));
            ps.setInt(6, Integer.parseInt(request.getParameter("id")));
            ps.executeUpdate();
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html>
<head>
<title>Class Capacity Management</title>

<style>
body {
    font-family: "Segoe UI", Tahoma, Arial, sans-serif;
    background: #f4f6f9;
    padding: 20px;
}

table {
    width: 55%;
    margin: 20px auto;
    background: #fff;
    border-radius: 8px;
    border-collapse: separate;
    border-spacing: 0;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}

th {
    background: #0f2a4d;
    color: white;
    padding: 12px;
}

td {
    padding: 10px;
    border-bottom: 1px solid #eee;
}

input {
    width: 100%;
    padding: 7px;
    border-radius: 6px;
    border: 1px solid #ccc;
}

.btn {
    padding: 7px 14px;
    border-radius: 6px;
    border: none;
    cursor: pointer;
    font-weight: 600;
}

.add { background: #4CAF50; color: white; }
.edit { background: #2196F3; color: white; }

td:last-child {
    text-align: center;
}
</style>
</head>

<body>

<jsp:include page="common_header.jsp" />
<h1 align="center">Class Capacity</h1>

<!-- ADD FORM -->
<form method="post">
<input type="hidden" name="action" value="add">
<table>
<tr>
    <th>Class</th>
    <th>Boarders</th>
    <th>Day Scholars</th>
    <th>Girls</th>
    <th>Boys</th>
    <th>Total</th>
    <th>Action</th>
</tr>
<tr>
    <td><input type="text" name="class_name" required></td>
    <td><input type="number" name="boarders" required></td>
    <td><input type="number" name="day_scholars" required></td>
    <td><input type="text" name="boarders_girls"></td>
    <td><input type="text" name="boarders_boys"></td>
    <td style="text-align:center;">Auto</td>
    <td><button class="btn add">Add</button></td>
</tr>
</table>
</form>

<!-- DOWNLOAD -->
<form method="post" style="text-align:center;">
    <input type="hidden" name="action" value="download">
    <button class="btn edit">Download Excel</button>
</form>

<!-- LIST -->
<table>
<tr>
    <th>ID</th>
    <th>Class</th>
    <th>Boarders</th>
    <th>Day Scholars</th>
    <th>Girls</th>
    <th>Boys</th>
    <th>Total</th>
    <th>Action</th>
</tr>

<%
    ps = con.prepareStatement("SELECT * FROM class_capacity ORDER BY id");
    rs = ps.executeQuery();
    while (rs.next()) {
%>
<form method="post">
<tr>
    <td><%= rs.getInt("id") %>
        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
    </td>
    <td><%= rs.getString("class_name") %></td>
    <td><input type="number" name="boarders" value="<%= rs.getInt("boarders") %>"></td>
    <td><input type="number" name="day_scholars" value="<%= rs.getInt("day_scholars") %>"></td>
    <td><input type="text" name="boarders_girls" value="<%= rs.getString("boarders_girls") %>"></td>
    <td><input type="text" name="boarders_boys" value="<%= rs.getString("boarders_boys") %>"></td>
    <td><b><%= rs.getInt("total_capacity") %></b></td>
    <td>
        <button class="btn edit" name="action" value="update">Update</button>
    </td>
</tr>
</form>
<% } %>

</table>

</body>
</html>
