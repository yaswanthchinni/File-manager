<%@ Page Language="C#" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="cc1" %>
<%@ Import Namespace = "System.IO" %>
<%@ Import Namespace = "System.Web.Services" %>
<%@ Import Namespace = "System.Web.Script.Services" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script language="javascript" type="text/javascript">
    var FileManager;
  
    function pageLoad()
    {
        FileManager=new BinaryIntellect.Web.UI.FileManager();

        var obj=document.getElementById('Panel5');
        obj.style.visibility="hidden";

        var obj=document.getElementById('Panel6');
        obj.style.visibility="hidden";
    }
</script>

<script runat="server">
    public class FileSystemItem
    {
        private string strName;
        private string strFullName;
        
        private DateTime dtCreationDate;
        private DateTime dtLastAccessDate;
        private DateTime dtLastWriteDate;
        
        private bool blnIsFolder;
        
        private long lngSize;
        private long lngFileCount;
        private long lngSubFolderCount;

        public string Name
        {
            get
            {
                return strName;
            }
            set
            {
                strName = value;
            }
        }

        public string FullName
        {
            get
            {
                return strFullName;
            }
            set
            {
                strFullName = value;
            }
        }

        public DateTime CreationDate
        {
            get
            {
                return dtCreationDate;
            }
            set
            {
                dtCreationDate = value;
            }
        }

        public bool IsFolder
        {
            get
            {
                return blnIsFolder;
            }
            set
            {
                blnIsFolder = value;
            }
        }

        public long Size
        {
            get
            {
                return lngSize;
            }
            set
            {
                lngSize = value;
            }
        }

        public DateTime LastAccessDate
        {
            get
            {
                return dtLastAccessDate;
            }
            set
            {
                dtLastAccessDate = value;
            }
        }

        public DateTime LastWriteDate
        {
            get
            {
                return dtLastWriteDate;
            }
            set
            {
                dtLastWriteDate = value;
            }
        }

        public long FileCount
        {
            get
            {
                return lngFileCount;
            }
            set
            {
                lngFileCount = value;
            }
        }

        public long SubFolderCount
        {
            get
            {
                return lngSubFolderCount;
            }
            set
            {
                lngSubFolderCount = value;
            }
        }
    }

    public class FileSystemManager
    {
        private static string strRootFolder;

        static FileSystemManager()
        {
            strRootFolder = HttpContext.Current.Request.PhysicalApplicationPath;
            strRootFolder = strRootFolder.Substring(0, strRootFolder.LastIndexOf(@"\"));
        }

        public static string GetRootPath()
        {
            return strRootFolder;
        }

        public static void SetRootPath(string path)
        {
            strRootFolder = path;
        }

        public static List<FileSystemItem> GetItems()
        {
            return GetItems(strRootFolder);
        }

        public static List<FileSystemItem> GetItems(string path)
        {
            string[] folders = Directory.GetDirectories(path);
            string[] files = Directory.GetFiles(path);
            List<FileSystemItem> list = new List<FileSystemItem>();
            foreach (string s in folders)
            {
                FileSystemItem item = new FileSystemItem();
                DirectoryInfo di = new DirectoryInfo(s);
                item.Name = di.Name;
                item.FullName = di.FullName;
                item.CreationDate = di.CreationTime;
                item.IsFolder = true;
                list.Add(item);
            }
            foreach (string s in files)
            {
                FileSystemItem item = new FileSystemItem();
                FileInfo fi = new FileInfo(s);
                item.Name = fi.Name;
                item.FullName = fi.FullName;
                item.CreationDate = fi.CreationTime;
                item.IsFolder = true;
                item.Size = fi.Length;
                list.Add(item);
            }

            if (path.ToLower() != strRootFolder.ToLower())
            {
                FileSystemItem topitem = new FileSystemItem();
                DirectoryInfo topdi = new DirectoryInfo(path).Parent;
                topitem.Name = "[Parent]";
                topitem.FullName = topdi.FullName;
                list.Insert(0, topitem);

                FileSystemItem rootitem = new FileSystemItem();
                DirectoryInfo rootdi = new DirectoryInfo(strRootFolder);
                rootitem.Name = "[Root]";
                rootitem.FullName = rootdi.FullName;
                list.Insert(0, rootitem);

            }
            return list;
        }

        public static void CreateFolder(string name, string parentName)
        {
            DirectoryInfo di = new DirectoryInfo(parentName);
            di.CreateSubdirectory(name);
        }

        public static void DeleteFolder(string path)
        {
            Directory.Delete(path);
        }

        public static void MoveFolder(string oldPath, string newPath)
        {
            Directory.Move(oldPath, newPath);
        }

        public static void CreateFile(string filename, string path)
        {
            FileStream fs = File.Create(path + "\\" + filename);
            fs.Close();
        }

        public static void CreateFile(string filename, string path, byte[] contents)
        {
            FileStream fs = File.Create(path + "\\" + filename);
            fs.Write(contents, 0, contents.Length);
            fs.Close();
        }

        public static void DeleteFile(string path)
        {
            File.Delete(path);
        }

        public static void MoveFile(string oldPath, string newPath)
        {
            File.Move(oldPath, newPath);
        }

        public static FileSystemItem GetItemInfo(string path)
        {
            FileSystemItem item = new FileSystemItem();
            if (Directory.Exists(path))
            {
                DirectoryInfo di = new DirectoryInfo(path);
                item.Name = di.Name;
                item.FullName = di.FullName;
                item.CreationDate = di.CreationTime;
                item.IsFolder = true;
                item.LastAccessDate = di.LastAccessTime;
                item.LastWriteDate = di.LastWriteTime;
                item.FileCount = di.GetFiles().Length;
                item.SubFolderCount = di.GetDirectories().Length;
            }
            else
            {
                FileInfo fi = new FileInfo(path);
                item.Name = fi.Name;
                item.FullName = fi.FullName;
                item.CreationDate = fi.CreationTime;
                item.LastAccessDate = fi.LastAccessTime;
                item.LastWriteDate = fi.LastWriteTime;
                item.IsFolder = false;
                item.Size = fi.Length;
            }
            return item;
        }

        public static void CopyFolder(string source, string destination)
        {
            String[] files;
            if (destination[destination.Length - 1] != Path.DirectorySeparatorChar)
                destination += Path.DirectorySeparatorChar;
            if (!Directory.Exists(destination)) Directory.CreateDirectory(destination);
            files = Directory.GetFileSystemEntries(source);
            foreach (string element in files)
            {
                if (Directory.Exists(element))
                    CopyFolder(element, destination + Path.GetFileName(element));
                else
                    File.Copy(element, destination + Path.GetFileName(element), true);
            }
        }
    }

</script>

<script runat="server">
  
    [WebMethod]
    public static FileSystemItem GetItemInfo(string path)
    {
        return FileSystemManager.GetItemInfo(path);
    }
  
    protected void Page_Load(object sender, EventArgs e)
    {
        GridView1.Attributes.Add("oncontextmenu", "return FileManager.ShowContextMenu(event);");
        GridView1.Attributes.Add("onmouseover", "return FileManager.HideContextMenu();return FileManager.HideItemInfo();");
        GridView1.Attributes.Add("onmousemove", "return FileManager.HideItemInfo();");
        
        if (!IsPostBack)
        {
            BindGrid();
        }
    }

    private void BindGrid()
    {
        List<FileSystemItem> list = FileSystemManager.GetItems();
        GridView1.DataSource = list;
        GridView1.DataBind();
        lblCurrentPath.Text = FileSystemManager.GetRootPath();
    }

    private void BindGrid(string path)
    {
        List<FileSystemItem> list = FileSystemManager.GetItems(path);
        GridView1.DataSource = list;
        GridView1.DataBind();
        lblCurrentPath.Text = path;
    }
    
    protected void btnDelete_Click(object sender, EventArgs e)
    {
        foreach(GridViewRow row in GridView1.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                CheckBox cb = (CheckBox)row.Cells[0].FindControl("CheckBox1");
                if (cb.Checked)
                {
                    LinkButton lb = (LinkButton)row.Cells[1].FindControl("LinkButton1");
                    if (Directory.Exists(lb.CommandArgument))
                    {
                        FileSystemManager.DeleteFolder(lb.CommandArgument);
                    }
                    else
                    {
                        FileSystemManager.DeleteFile(lb.CommandArgument);
                    }
                }
            }
        }
        BindGrid(lblCurrentPath.Text);
    }

    protected void GridView1_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            CheckBox cb = (CheckBox)e.Row.Cells[0].FindControl("chkHeader");
            cb.Attributes.Add("onclick", "FileManager.ToggleSelectionForAllItems(event);");
        }
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            CheckBox cb = (CheckBox)e.Row.Cells[0].FindControl("CheckBox1");
            cb.Attributes.Add("onclick", "FileManager.UnselectHeaderCheckBox(event);");

            LinkButton lb = (LinkButton)e.Row.Cells[1].FindControl("LinkButton1");
            if (lb.Text != "[Root]" && lb.Text != "[Parent]")
            {
                lb.Attributes.Add("onmousemove", "FileManager.BeginShowItemInfo(event);");
                lb.Attributes.Add("onmouseout", "FileManager.HideItemInfo();");
                lb.Attributes.Add("onmouseleave", "FileManager.BeginShowItemInfo(event);");
            }
            else
            {
                e.Row.Cells[0].Controls.Clear();
            }
        }
    }

    protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (Directory.Exists(e.CommandArgument.ToString()))
        {
            BindGrid(e.CommandArgument.ToString());
        }
        else
        {
            string path=e.CommandArgument.ToString();
            path = path.Replace(FileSystemManager.GetRootPath(), "~");
            path = path.Replace("\\", "/");
            Response.Redirect(path);
        }
    }

    protected void btnCreate_Click(object sender, EventArgs e)
    {
        FileSystemManager.CreateFolder(TextBox2.Text, lblCurrentPath.Text);
        BindGrid(lblCurrentPath.Text);
    }


    protected void btnPanel3Ok_Click(object sender, EventArgs e)
    {
        if (FileUpload1.HasFile)
        {
            string path = lblCurrentPath.Text;
            path += Path.GetFileName(FileUpload1.FileName);
            FileUpload1.PostedFile.SaveAs(path);
            BindGrid(lblCurrentPath.Text);
        }
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        if (FileUpload1.HasFile)
        {
            string path = lblCurrentPath.Text + "\\";
            path += Path.GetFileName(FileUpload1.FileName);
            FileUpload1.PostedFile.SaveAs(path);
            BindGrid(lblCurrentPath.Text);
        }
    }

    protected void btnCut_Click(object sender, EventArgs e)
    {
        List<string> items = new List<string>();
        foreach (GridViewRow row in GridView1.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                CheckBox cb = (CheckBox)row.Cells[0].FindControl("CheckBox1");
                if (cb.Checked)
                {
                    LinkButton lb = (LinkButton)row.Cells[1].FindControl("LinkButton1");
                    items.Add(lb.CommandArgument);
                }
            }
        }
        ViewState["clipboard"] = items;
        ViewState["action"] = "cut";
    }

    protected void btnPaste_Click(object sender, EventArgs e)
    {
        if (ViewState["clipboard"] != null)
        {
            if (ViewState["action"].ToString() == "cut")
            {
                List<string> items = (List<string>)ViewState["clipboard"];
                foreach (string s in items)
                {
                    if (Directory.Exists(s))
                    {
                        Directory.Move(s, lblCurrentPath.Text + s.Substring(s.LastIndexOf("\\")));
                    }
                    else
                    {
                        File.Move(s, lblCurrentPath.Text + "\\" + Path.GetFileName(s));
                    }
                }
            }
            else
            {
                List<string> items = (List<string>)ViewState["clipboard"];
                foreach (string s in items)
                {
                    if (Directory.Exists(s))
                    {
                        DirectoryInfo di = new DirectoryInfo(s);
                        FileSystemManager.CopyFolder(s, lblCurrentPath.Text + "\\" + di.Name);
                    }
                    else
                    {
                        File.Copy(s, lblCurrentPath.Text + "\\" + Path.GetFileName(s));
                    }
                }
            }            
        }
        ViewState["clipboard"] = null;
        ViewState["action"] = null;
        BindGrid(lblCurrentPath.Text);
    }

    protected void btnCopy_Click(object sender, EventArgs e)
    {
        List<string> items = new List<string>();
        foreach (GridViewRow row in GridView1.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                CheckBox cb = (CheckBox)row.Cells[0].FindControl("CheckBox1");
                if (cb.Checked)
                {
                    LinkButton lb = (LinkButton)row.Cells[1].FindControl("LinkButton1");
                    items.Add(lb.CommandArgument);
                }
            }
        }
        ViewState["clipboard"] = items;
        ViewState["action"] = "copy";
    }

    protected void btnRename_Click(object sender, EventArgs e)
    {
        string src = "";
        string dest = "";
        foreach (GridViewRow row in GridView1.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                CheckBox cb = (CheckBox)row.Cells[0].FindControl("CheckBox1");
                if (cb.Checked)
                {
                    LinkButton lb = (LinkButton)row.Cells[1].FindControl("LinkButton1");
                    src = lb.CommandArgument;
                }
            }
        }
        dest = src.Substring(0, src.LastIndexOf('\\'));
        dest = dest + "\\" + TextBox3.Text;
        if (Directory.Exists(src))
        {
            FileSystemManager.MoveFolder(src, dest);
        }
        else
        {
            FileSystemManager.MoveFile(src, dest);            
        }
        BindGrid(lblCurrentPath.Text);
    }

    protected void CheckBox2_CheckedChanged(object sender, EventArgs e)
    {
        CheckBox cbHeader = (CheckBox)sender;
        foreach (GridViewRow row in GridView1.Rows)
        {
            if (row.RowType == DataControlRowType.DataRow)
            {
                CheckBox cb = (CheckBox)row.Cells[0].FindControl("CheckBox1");
                cb.Checked = cbHeader.Checked;
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>BinaryIntellect Web Site File Manager</title>
    <style type="text/css">
        .DynamicPanel
        {
            border-right: darkgray 2px solid;
            border-top: darkgray 2px solid;
            border-left: darkgray 2px solid;
            border-bottom: darkgray 2px solid;
            background-color: #E0E0E0;
            Width:300px;   
            position: absolute;
            left: 0px;
            top: 0px;
        }
        .modalBackground {
    	background-color:Gray;
	    filter:alpha(opacity=70);
	    opacity:0.7;
        }
    </style>
</head>
<body style="font-family:Verdana;font-size:12px">
    <form id="form1" runat="server">
    <div>
        <asp:Panel ID="Panel7" runat="server" BackColor="#E0E0E0" BorderColor="Silver" Width="100%" BorderStyle="Solid" BorderWidth="1px">
        <center>
        <asp:Label ID="Label15" runat="server" Font-Size="25px" ForeColor="#0000C0" Text="Web Site File Manager"></asp:Label>
            <br />
            &nbsp;
        </center>            
         </asp:Panel>
         <br />
         <br />
        <cc1:DropShadowExtender ID="DropShadowExtender1" runat="server" TargetControlID="Panel7" Opacity="90" >
        </cc1:DropShadowExtender>
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="True">
        </asp:ScriptManager>


<!-- FileManager Class Begin -->
<script type="text/javascript">

Type.registerNamespace("BinaryIntellect.Web.UI");

BinaryIntellect.Web.UI.FileManager = function() 
{
    this._x;
    this._y;
}

BinaryIntellect.Web.UI.FileManager.prototype = 
{
    GetMouseX:function()
    {
        return this._x;
    },
    
    SetMouseX:function(value)
    {
        this._x=value;
    },
    
    GetMouseY:function()
    {
        return this._y;
    },
    
    SetMouseY:function(value)
    {
        this._y=value;
    },
   
    ShowContextMenu:function(evt)
    {
        var obj=document.getElementById('Panel5');
        obj.style.visibility="visible";
        obj.style.position="absolute";
        if(evt.x)
        {
            obj.style.posLeft=event.x;
            obj.style.posTop=event.y;
        }
        else
        {
            obj.style.left=evt.layerX + "px";
            obj.style.top=evt.layerY + "px";
        }
        return false;
    },
    
    HideContextMenu:function()
    {
        var obj=document.getElementById('Panel5');
        obj.style.visibility="hidden";
        return false;
    },
    
    ClickButton:function(srcElement)
    {
        FileManager.HideContextMenu();
        document.getElementById(srcElement).click();
        return false;
    },
    
    ToggleSelectionForAllItems:function(evt)
    {
        var count=0;
        var items=document.form1.getElementsByTagName("input");
        for(i=0;i<items.length;i++)
        {
            if(items[i].type=="checkbox")
            {
                if(evt.srcElement)
                {
                    if(items[i].id!=evt.srcElement.id)
                    {
                        items[i].checked=evt.srcElement.checked;
                        count++;
                    }
                }
                else
                {
                    if(items[i].id!=evt.target.id)
                    {
                        items[i].checked=evt.target.checked;
                        count++;
                    }
                }
            }
        }
    },
    
    UnselectHeaderCheckBox:function(evt)
    {
        if(evt.srcElement)
        {
            if(event.srcElement.checked==false)
            {
                var count=0;
                var items=document.form1.getElementsByTagName("input");
                for(i=0;i<items.length;i++)
                {
                    if(items[i].type=="checkbox")
                    {
                        if(items[i].id.indexOf('chkHeader')>0)
                        {
                            items[i].checked=false;
                        }
                    }
                }
            }
        }
        else
        {
            if(evt.target.checked==false)
            {
                var count=0;
                var items=document.form1.getElementsByTagName("input");
                for(i=0;i<items.length;i++)
                {
                    if(items[i].type=="checkbox")
                    {
                        if(items[i].id.indexOf('chkHeader')>0)
                        {
                            items[i].checked=false;
                        }
                    }
                }
            }
        }
    },
    
    BeginShowItemInfo:function(evt)
    {
        if(document.getElementById('chkSmartTips').checked)
        {
            if(evt.srcElement)
            {
                var path=document.getElementById('lblCurrentPath').innerText;
                path = path + "\\" + event.srcElement.innerText;
                FileManager.SetMouseX(event.x);
                FileManager.SetMouseY(event.y);
            }
            else
            {
                var path=document.getElementById('lblCurrentPath').textContent;
                path = path + "\\" + evt.target.textContent;
                FileManager.SetMouseX(evt.layerX);
                FileManager.SetMouseY(evt.layerY);
            }
            PageMethods.GetItemInfo(path,FileManager.EndShowItemInfo,FileManager.OnError);
        }
    },
    
    EndShowItemInfo:function(result)
    {
        var obj=document.getElementById('Panel6');
        obj.style.visibility="visible";
        obj.style.position="absolute";
        if(obj.style.posLeft)
        {
            obj.style.posLeft=FileManager.GetMouseX();
            obj.style.posTop=FileManager.GetMouseY();
        }
        else
        {
            obj.style.left=FileManager.GetMouseX() + "px";
            obj.style.top=FileManager.GetMouseY() + "px";
        }
        if(document.getElementById('lblFullName').innerText!=null)
        {
            document.getElementById('lblFullName').innerText=result.FullName;
            document.getElementById('lblCreatedOn').innerText=result.CreationDate;
            document.getElementById('lblLastAccess').innerText=result.LastAccessDate;
            document.getElementById('lblLastWrite').innerText=result.LastWriteDate;
            if(result.IsFolder)
            {
                document.getElementById('lblFileCount').innerText=result.FileCount;
            }
            else
            {
                document.getElementById('lblFileCount').innerText="-";
            }
            if(result.IsFolder)
            {
                document.getElementById('lblSubfolderCount').innerText=result.SubFolderCount;
            }
            else
            {
                document.getElementById('lblSubfolderCount').innerText="-";
            }
            if(result.IsFolder==false)
            {
                document.getElementById('lblSize').innerText=result.Size + " bytes";
            }
            else
            {
                document.getElementById('lblSize').innerText="-";
            }
        }
        else
        {
            document.getElementById('lblFullName').textContent=result.FullName;
            document.getElementById('lblCreatedOn').textContent=result.CreationDate;
            document.getElementById('lblLastAccess').textContent=result.LastAccessDate;
            document.getElementById('lblLastWrite').textContent=result.LastWriteDate;
            if(result.IsFolder)
            {
                document.getElementById('lblFileCount').textContent=result.FileCount;
            }
            else
            {
                document.getElementById('lblFileCount').textContent="-";
            }
            if(result.IsFolder)
            {
                document.getElementById('lblSubfolderCount').textContent=result.SubFolderCount;
            }
            else
            {
                document.getElementById('lblSubFolderCount').textContent="-";
            }
            if(result.IsFolder==false)
            {
                document.getElementById('lblSize').textContent=result.Size + " bytes";
            }
            else
            {
                document.getElementById('lblSize').textContent="-";
            }
            obj.style.overflow="auto";
        }
    },
    
    OnError:function(result)
    {
        if(result.get_exceptionType()=="System.IO.FileNotFoundException")
        {
            //do nothing    
        }
        else
        {
            alert(result.get_message());
        }
        
    },
    
    HideItemInfo:function()
    {
        var obj=document.getElementById('Panel6');
        obj.style.visibility="hidden";
        event.returnValue=false;
    },
    
    GetSelectedItemCount:function()
    {
        var count=0;
        var items=document.form1.getElementsByTagName("input");
        for(i=0;i<items.length;i++)
        {
            if(items[i].type=="checkbox")
            {
                if(items[i].checked)
                {
                    if(items[i].id!='chkSmartTips')
                    {
                        count++;
                    }
                }
            }
        }
        return count;
    },
    
    Rename:function()
    {
        if(document.getElementById('TextBox3').value=="")
        {
            alert("Please enter new name!");
            return false;
        }
        var count=0;
        count=FileManager.GetSelectedItemCount();
        if(count==0)
        {
            alert("Please select an item to rename");
            return false;
        }
        if(count>1)
        {
            alert("Please select only one item to rename");
            return false;
        }
        else
        {
            __doPostBack('btnRename','');
        }
    },
    
    Cut:function()
    {
        var count=0;
        var items=document.form1.getElementsByTagName("input");
        count=FileManager.GetSelectedItemCount();
        if(count==0)
        {
            alert("Please select an item to cut");
            return false;
        }
        else
        {
            __doPostBack('btnRename','');
        }
    },
    
    Paste:function()
    {
        __doPostBack('btnPaste','');
    },
    
    Copy:function()
    {
        var count=0;
        var items=document.form1.getElementsByTagName("input");
        count=FileManager.GetSelectedItemCount();
        if(count==0)
        {
            alert("Please select an item to copy");
            return false;
        }
        else
        {
            __doPostBack('btnCopy','');
        }
    },
    
    Create:function()
    {
        if(document.getElementById('TextBox2').value=="")
        {
            alert("Please enter folder name!");
            return false;
        }
        else
        {
            __doPostBack('btnCreate','');
        }
    },
    
    Delete:function()
    {
        var count=0;
        var items=document.form1.getElementsByTagName("input");
        count=FileManager.GetSelectedItemCount();
        if(count==0)
        {
            alert("Please select items to delete");
            return false;
        }
        else
        {
            __doPostBack('btnDelete','')
        }
    },
    
    Upload:function()
    {
        if(document.getElementById('FileUpload1').value=="")
        {
            alert("Please select file to upload!");
            return false;
        }
        else
        {
            __doPostBack('btnUpload','');
        }
    }
}

BinaryIntellect.Web.UI.FileManager.registerClass('BinaryIntellect.Web.UI.FileManager', null, Sys.IDisposable);

</script>
<!-- FileManager Class End -->

    </div>
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <table style="width: 100%">
                    <tr>
                        <td align="left">
                            <asp:Button ID="btnCreate" runat="server" Text="Create" Width="75px" OnClick="btnCreate_Click" ToolTip="Create a new folder" />
                            <asp:Button ID="btnCut" runat="server" Text="Cut" Width="75px" OnClick="btnCut_Click" OnClientClick="return FileManager.Cut();" ToolTip="Cut selected items" />
                            <asp:Button ID="btnCopy" runat="server" Text="Copy" Width="75px" OnClick="btnCopy_Click" OnClientClick="return FileManager.Copy();" ToolTip="Copy selected items "  />
                            <asp:Button ID="btnPaste" runat="server" Text="Paste" Width="75px" OnClick="btnPaste_Click" ToolTip="Paste selected items inside current folder"  />
                            <asp:Button ID="btnRename" runat="server" Text="Rename" Width="75px" OnClick="btnRename_Click" ToolTip="Rename selected item" />
                            <asp:Button ID="btnDelete" runat="server" Text="Delete" Width="75px" OnClick="btnDelete_Click" ToolTip="Delete selected items" />
                            <cc1:modalpopupextender id="ModalPopupExtender1" runat="server" TargetControlID="btnDelete" PopupControlID="Panel1" OkControlID="btnYes" CancelControlID="btnNo" OnOkScript="FileManager.Delete();" DropShadow="true" BackgroundCssClass="modalBackground"></cc1:modalpopupextender>
                            <cc1:modalpopupextender id="Modalpopupextender2" runat="server" TargetControlID="btnCreate" PopupControlID="Panel2" OkControlID="btnPanel2Yes" CancelControlID="btnPanel2No" OnOkScript="FileManager.Create();" DropShadow="true" BackgroundCssClass="modalBackground"></cc1:modalpopupextender>
                            <cc1:modalpopupextender id="Modalpopupextender4" runat="server" TargetControlID="btnRename" PopupControlID="Panel4" OkControlID="btnPanel4Ok" CancelControlID="btnPanel4Cancel" OnOkScript="FileManager.Rename();" DropShadow="true" BackgroundCssClass="modalBackground"></cc1:ModalPopupExtender>
    </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="Label4" runat="server" Font-Bold="True" Text="Current Path :" Font-Names="Verdana" Font-Size="12px"></asp:Label>
                            <asp:Label ID="lblCurrentPath" runat="server" Font-Bold="True" Font-Names="Verdana" Font-Size="12px"></asp:Label></td>
                    </tr>
                    <tr>
                        <td>
                <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" CellPadding="4"
                    ForeColor="#333333" GridLines="Vertical" Width="100%" OnRowCommand="GridView1_RowCommand" Font-Names="Verdana" Font-Size="12px" OnRowDataBound="GridView1_RowDataBound">
                    <FooterStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                    <Columns>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:CheckBox ID="CheckBox1" runat="server" />
                            </ItemTemplate>
                            <HeaderTemplate>
                                <asp:CheckBox ID="chkHeader" runat="server" OnCheckedChanged="CheckBox2_CheckedChanged" />
                            </HeaderTemplate>
                            <ItemStyle Width="1%" Wrap="False" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Name">
                            <EditItemTemplate>
                                <asp:TextBox ID="TextBox1" runat="server" Text='<%# Bind("Name") %>'></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:LinkButton ID="LinkButton1" runat="server" CommandArgument='<%# Eval("FullName") %>'
                                    Text='<%# Eval("Name") %>'></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="CreationDate" HeaderText="Created On" >
                            <ItemStyle Width="5%" Wrap="False" />
                        </asp:BoundField>
                        <asp:BoundField DataField="Size" HeaderText="Size" >
                            <ItemStyle HorizontalAlign="Right" Width="5%" Wrap="False" />
                        </asp:BoundField>
                    </Columns>
                    <RowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                    <EditRowStyle BackColor="#999999" />
                    <SelectedRowStyle BackColor="#E2DED6" Font-Bold="True" ForeColor="#333333" />
                    <PagerStyle BackColor="#284775" ForeColor="White" HorizontalAlign="Center" />
                    <HeaderStyle BackColor="#5D7B9D" Font-Bold="True" ForeColor="White" />
                    <AlternatingRowStyle BackColor="White" ForeColor="#284775" />
                </asp:GridView>
                            </td>
                    </tr>
                    <tr>
                        <td align="left">
                            <asp:Button ID="Button1" runat="server" Text="Create" Width="75px" OnClick="btnCreate_Click" OnClientClick="return FileManager.ClickButton('btnCreate');" ToolTip="Create a new folder" />
                            <asp:Button ID="Button2" runat="server" Text="Cut" Width="75px" OnClick="btnCut_Click" OnClientClick="return FileManager.ClickButton('btnCut');" ToolTip="Cut selected items" />
                            <asp:Button ID="Button3" runat="server" Text="Copy" Width="75px" OnClick="btnCopy_Click" OnClientClick="return FileManager.ClickButton('btnCopy');" ToolTip="Copy selected items"  />
                            <asp:Button ID="Button4" runat="server" Text="Paste" Width="75px" OnClick="btnPaste_Click" OnClientClick="return FileManager.ClickButton('btnPaste');" ToolTip="Paste selected items"  />
                            <asp:Button ID="Button5" runat="server" Text="Rename" Width="75px" OnClick="btnRename_Click" OnClientClick="return FileManager.ClickButton('btnRename');" ToolTip="Rename selected item" />
                            <asp:Button ID="Button6" runat="server" Text="Delete" Width="75px" OnClick="btnDelete_Click" OnClientClick="return FileManager.ClickButton('btnDelete');" ToolTip="Delete selected items" /></td>
                    </tr>
                </table>
                &nbsp;
            </ContentTemplate>
        </asp:UpdatePanel>
        <asp:LinkButton ID="btnUpload" runat="server" OnClick="btnUpload_Click" Font-Bold="True">Upload a file to this folder</asp:LinkButton>
        <cc1:modalpopupextender id="Modalpopupextender3" runat="server" TargetControlID="btnUpload" PopupControlID="Panel3" OkControlID="btnPanel3Ok" CancelControlID="btnPanel3Cancel" OnOkScript="FileManager.Upload();" DropShadow="true" BackgroundCssClass="modalBackground"></cc1:modalpopupextender>
        <br />
        <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="UpdatePanel1">
            <ProgressTemplate>
                <asp:Label ID="Label1" runat="server" Font-Bold="True" ForeColor="Red" Text="Please wait..."></asp:Label>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <asp:Panel ID="Panel1" runat="server" CssClass="DynamicPanel">
            <table style="width: 100%">
                <tr>
                    <td align="center">
                        <asp:Label ID="Label2" runat="server" Font-Bold="True" Text="All the contents of the selected file or folder will be deleted. Do you wish to continue?"></asp:Label></td>
                </tr>
                <tr>
                    <td align="center">
                        <asp:Button ID="btnYes" runat="server" Text="Yes" Width="75px" />
                        <asp:Button ID="btnNo" runat="server" Text="No" Width="75px" /></td>
                </tr>
            </table>
        </asp:Panel>
        <asp:Panel ID="Panel2" runat="server" CssClass="DynamicPanel">
            <table style="width: 100%">
                <tr>
                    <td align="center">
                        <asp:Label ID="Label3" runat="server" Font-Bold="True" Text="Enter the folder name to create :"></asp:Label></td>
                </tr>
                <tr>
                    <td align="center">
                        <asp:TextBox ID="TextBox2" runat="server"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="center">
                        &nbsp;<asp:Button ID="btnPanel2Yes" runat="server" Text="OK" Width="75px" />
                        <asp:Button ID="btnPanel2No" runat="server" Text="Cancel" Width="75px" /></td>
                </tr>
            </table>
        </asp:Panel>
        <asp:Panel ID="Panel3" runat="server" CssClass="DynamicPanel">
            <table style="width: 100%">
                <tr>
                    <td align="center">
                        <asp:Label ID="Label6" runat="server" Font-Bold="True" Text="Select file to be uploaded :"></asp:Label></td>
                </tr>
                <tr>
                    <td align="center"><asp:FileUpload
                                ID="FileUpload1" runat="server" /></td>
                </tr>
                <tr>
                    <td align="center">
                        &nbsp;<asp:Button ID="btnPanel3Ok" runat="server" Text="OK" Width="75px" />
                        <asp:Button ID="btnPanel3Cancel" runat="server" Text="Cancel" Width="75px" /></td>
                </tr>
            </table>
        </asp:Panel>
        <asp:Panel ID="Panel4" runat="server" CssClass="DynamicPanel">
            <table style="width: 100%" cellpadding="5">
                <tr>
                    <td align="center">
                        <asp:Label ID="Label5" runat="server" Font-Bold="True" Text="Enter new name for the selected item :"></asp:Label></td>
                </tr>
                <tr>
                    <td align="center">
                        <asp:TextBox ID="TextBox3" runat="server"></asp:TextBox></td>
                </tr>
                <tr>
                    <td align="center">
                        &nbsp;<asp:Button ID="btnPanel4Ok" runat="server" Text="OK" Width="75px" />
                        <asp:Button ID="btnPanel4Cancel" runat="server" Text="Cancel" Width="75px" /></td>
                </tr>
            </table>
        </asp:Panel>
        <asp:Panel ID="Panel5" runat="server" CssClass="DynamicPanel" Width="150px">
            <table style="width: 100%">
                <tr>
                    <td align="left">
                        <asp:LinkButton ID="LinkButton2" runat="server" OnClientClick="return FileManager.ClickButton('btnCreate');">Create</asp:LinkButton></td>
                </tr>
                <tr>
                    <td align="left">
                        <hr />
                        </td>
                </tr>
                <tr>
                    <td align="left">
                        <asp:LinkButton ID="LinkButton3" runat="server" OnClientClick="return FileManager.ClickButton('btnCut');">Cut</asp:LinkButton></td>
                </tr>
                <tr>
                    <td align="left">
                        <asp:LinkButton ID="LinkButton4" runat="server" OnClientClick="return FileManager.ClickButton('btnCopy');">Copy</asp:LinkButton></td>
                </tr>
                <tr>
                    <td align="left">
                        <asp:LinkButton ID="LinkButton5" runat="server" OnClientClick="return FileManager.ClickButton('btnPaste');">Paste</asp:LinkButton></td>
                </tr>
                <tr>
                    <td align="left">
                        <hr />
                        </td>
                </tr>
                <tr>
                    <td align="left">
                        <asp:LinkButton ID="LinkButton6" runat="server" OnClientClick="return FileManager.ClickButton('btnRename');">Rename</asp:LinkButton></td>
                </tr>
                <tr>
                    <td align="left" style="height: 21px">
                        <asp:LinkButton ID="LinkButton7" runat="server" OnClientClick="return FileManager.ClickButton('btnDelete');">Delete</asp:LinkButton></td>
                </tr>
                <tr>
                    <td align="left" style="height: 21px">
                        <hr />
                    </td>
                </tr>
                <tr>
                    <td align="left" style="height: 21px">
                        <asp:LinkButton ID="LinkButton8" runat="server" OnClientClick="return FileManager.ClickButton('btnUpload');">Upload File</asp:LinkButton></td>
                </tr>
                <tr>
                    <td align="left" style="height: 21px">
                        <hr />
                        </td>
                </tr>
                <tr>
                    <td align="left" style="height: 21px">
                        <asp:CheckBox ID="chkSmartTips" runat="server" Font-Bold="True" Text="Show Smart Tips" Checked="True" /></td>
                </tr>
            </table>
        </asp:Panel>
        &nbsp;
        <cc1:TextBoxWatermarkExtender ID="TextBoxWatermarkExtender2" runat="server" TargetControlID="TextBox3" WatermarkText="Enter new name for the selected item">
        </cc1:TextBoxWatermarkExtender>
        &nbsp;
        <cc1:TextBoxWatermarkExtender ID="TextBoxWatermarkExtender1" runat="server" TargetControlID="TextBox2" WatermarkText="Enter folder name to create">
        </cc1:TextBoxWatermarkExtender>
        &nbsp;
        &nbsp;
        &nbsp;
        &nbsp;
        <cc1:modalpopupextender id="Modalpopupextender5" runat="server" TargetControlID="LinkButton8" PopupControlID="Panel3" OkControlID="btnPanel3Ok" CancelControlID="btnPanel3Cancel" OnOkScript="FileManager.Upload();">
        </cc1:ModalPopupExtender>
        <asp:Panel ID="Panel6" runat="server" CssClass="DynamicPanel" width="500px">
            <table id="tblInfo" style="width: 100%">
                <tr>
                    <td style="overflow: visible; width: 150px" align="right" nowrap>
                        <asp:Label ID="Label7" runat="server" Text="Full Name :" Font-Bold="True"></asp:Label></td>
                    <td nowrap>
                        <asp:Label ID="lblFullName" runat="server" Font-Bold="True"></asp:Label></td>
                </tr>
                <tr>
                    <td style="overflow: visible; width: 150px" align="right" nowrap>
                        <asp:Label ID="Label8" runat="server" Text="Created On :" Font-Bold="True"></asp:Label></td>
                    <td nowrap>
                        <asp:Label ID="lblCreatedOn" runat="server" Font-Bold="True"></asp:Label></td>
                </tr>
                <tr>
                    <td style="overflow: visible; width: 150px" align="right" nowrap>
                        <asp:Label ID="Label9" runat="server" Text="Last Accessed On :" Font-Bold="True"></asp:Label></td>
                    <td nowrap>
                        <asp:Label ID="lblLastAccess" runat="server" Font-Bold="True"></asp:Label></td>
                </tr>
                <tr>
                    <td style="overflow: visible; width: 150px" align="right" nowrap>
                        <asp:Label ID="Label10" runat="server" Text="Last Modified On :" Font-Bold="True"></asp:Label></td>
                    <td nowrap>
                        <asp:Label ID="lblLastWrite" runat="server" Font-Bold="True"></asp:Label></td>
                </tr>
                <tr>
                    <td style="overflow: visible; width: 150px" align="right" nowrap>
                        <asp:Label ID="Label11" runat="server" Text="File Count :" Font-Bold="True"></asp:Label></td>
                    <td nowrap>
                        <asp:Label ID="lblFileCount" runat="server" Font-Bold="True"></asp:Label></td>
                </tr>
                <tr>
                    <td style="overflow: visible; width: 150px" align="right" nowrap>
                        <asp:Label ID="Label12" runat="server" Text="Subfolder Count :" Font-Bold="True"></asp:Label></td>
                    <td nowrap>
                        <asp:Label ID="lblSubFolderCount" runat="server" Font-Bold="True"></asp:Label></td>
                </tr>
                <tr>
                    <td style="overflow: visible; width: 150px" align="right" nowrap>
                        <asp:Label ID="Label13" runat="server" Text="Size :" Font-Bold="True"></asp:Label></td>
                    <td nowrap>
                        <asp:Label ID="lblSize" runat="server" Font-Bold="True"></asp:Label></td>
                </tr>
            </table>
        </asp:Panel>
        &nbsp;&nbsp;
        <asp:Panel ID="Panel8" runat="server" BackColor="#E0E0E0" BorderColor="Silver" BorderStyle="Solid" BorderWidth="1px" Width="100%">
        <center>
        &nbsp;
        <br />
        <asp:Label ID="Label16" runat="server" Font-Bold="True" ForeColor="#0000C0" Text="Copyright (C) BinaryIntellect Consulting. All rights reserved."></asp:Label>
        <br />
        <asp:HyperLink ID="HyperLink1" runat="server" Font-Bold="True" ForeColor="#0000C0"
            NavigateUrl="http://www.binaryintellect.net">Visit us at www.binaryintellect.net</asp:HyperLink>
            <br />
            &nbsp;
            <br />
            </center>
            </asp:Panel><cc1:DropShadowExtender ID="DropShadowExtender2" runat="server" Opacity="90" TargetControlID="Panel8">
            </cc1:DropShadowExtender>
    </form>
</body>
</html>
