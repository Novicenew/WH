@echo off
chcp 65001
echo ===== Hexo图片处理工具 =====

:menu
echo.
echo ========= 图片处理菜单 =========
echo 1. 扫描并修复所有文章图片引用
echo 2. 批量优化图片大小(压缩)
echo 3. 批量重命名图片(移除中文和特殊字符)
echo 4. 导入剪贴板图片到文章
echo 5. 创建文章图片目录
echo 6. 退出
echo ==============================
echo.
set /p choice=请选择操作 (1-6): 

if "%choice%"=="1" goto scan_fix_images
if "%choice%"=="2" goto optimize_images
if "%choice%"=="3" goto rename_images
if "%choice%"=="4" goto import_clipboard
if "%choice%"=="5" goto create_post_dir
if "%choice%"=="6" goto end
goto menu

:scan_fix_images
echo.
echo 正在扫描并修复所有文章的图片引用...

:: 使用PowerShell扫描修复所有Markdown文件中的图片引用
powershell -Command ^"^
Get-ChildItem 'source/_posts' -Filter *.md -Recurse | ForEach-Object { ^
    $mdFile = $_.FullName; ^
    $folder = $_.BaseName; ^
    $content = Get-Content -Path $mdFile -Raw -Encoding UTF8; ^
    if ($null -eq $content) { ^
        Write-Host ('无法读取文件: ' + $mdFile) -ForegroundColor Red; ^
        return; ^
    } ^
    $modified = $false; ^
    $matches = [regex]::Matches($content, '!\[(.*?)\]\(((?!http|/img).*?)\)'); ^
    foreach ($match in $matches) { ^
        $imgAlt = $match.Groups[1].Value; ^
        $imgPath = $match.Groups[2].Value; ^
        $imgName = Split-Path $imgPath -Leaf; ^
        $destFolder = Join-Path 'source\_posts' $folder; ^
        if (!(Test-Path $destFolder)) { ^
            Write-Host ('创建文章图片目录: ' + $destFolder); ^
            New-Item -ItemType Directory -Path $destFolder -Force | Out-Null; ^
        } ^
        $srcFile = Join-Path (Split-Path $mdFile) $imgPath; ^
        $destFile = Join-Path $destFolder $imgName; ^
        $correctPath = $imgName; ^
        if (Test-Path $srcFile) { ^
            Write-Host ('复制图片: ' + $imgPath + ' -> ' + $destFile); ^
            Copy-Item -Path $srcFile -Destination $destFile -Force; ^
            if ($imgPath -ne $correctPath) { ^
                Write-Host ('修复图片引用: ' + $imgPath + ' -> ' + $correctPath) -ForegroundColor Green; ^
                $content = $content -replace [regex]::Escape('!['+ $imgAlt + '](' + $imgPath + ')'), ('![' + $imgAlt + '](' + $correctPath + ')'); ^
                $modified = $true; ^
            } ^
        } else { ^
            $altSrcFile = Join-Path (Split-Path $mdFile) $folder $imgPath; ^
            if (Test-Path $altSrcFile) { ^
                Write-Host ('复制图片(备选路径): ' + $imgPath + ' -> ' + $destFile); ^
                Copy-Item -Path $altSrcFile -Destination $destFile -Force; ^
                if ($imgPath -ne $correctPath) { ^
                    Write-Host ('修复图片引用: ' + $imgPath + ' -> ' + $correctPath) -ForegroundColor Green; ^
                    $content = $content -replace [regex]::Escape('!['+ $imgAlt + '](' + $imgPath + ')'), ('![' + $imgAlt + '](' + $correctPath + ')'); ^
                    $modified = $true; ^
                } ^
            } else { ^
                Write-Host ('图片不存在，无法修复: ' + $imgPath) -ForegroundColor Red; ^
            } ^
        } ^
    } ^
    if ($modified) { ^
        Set-Content -Path $mdFile -Value $content -Encoding UTF8; ^
        Write-Host ('已更新文件: ' + $mdFile) -ForegroundColor Cyan; ^
    } ^
}^"

echo.
echo 图片扫描和修复完成!
echo 提示：如果您的图片引用不正确，可能是因为图片路径有误或文件不存在
echo.
pause
goto menu

:optimize_images
echo.
echo 注意: 需要已安装ImageMagick才能优化图片
echo 是否已安装ImageMagick? (Y/N)
set /p have_imagemagick=

if /i not "%have_imagemagick%"=="Y" (
    echo.
    echo 请先安装ImageMagick: https://imagemagick.org/script/download.php
    echo 然后重新运行此选项
    pause
    goto menu
)

echo.
echo 选择要优化的图片范围:
echo 1. 优化所有文章图片
echo 2. 优化全局图片(/img目录)
echo 3. 返回上级菜单
set /p optimize_choice=请选择操作 (1-3): 

if "%optimize_choice%"=="1" (
    echo 正在批量优化文章图片...
    powershell -Command ^"^
    Get-ChildItem 'source/_posts' -Directory | ForEach-Object { ^
        $postDir = $_.FullName; ^
        $images = Get-ChildItem $postDir -File -Include *.jpg,*.jpeg,*.png,*.gif -Recurse; ^
        foreach ($img in $images) { ^
            Write-Host ('优化图片: ' + $img.FullName); ^
            try { ^
                magick $img.FullName -strip -interlace Plane -quality 85%% $img.FullName; ^
                Write-Host ('已优化: ' + $img.Name) -ForegroundColor Green; ^
            } catch { ^
                Write-Host ('优化失败: ' + $img.Name + ' - ' + $_.Exception.Message) -ForegroundColor Red; ^
            } ^
        } ^
    }^"
) else if "%optimize_choice%"=="2" (
    echo 正在优化全局图片...
    if not exist "source\img" (
        echo 创建全局图片目录...
        mkdir "source\img"
    )
    powershell -Command ^"^
    $images = Get-ChildItem 'source/img' -File -Include *.jpg,*.jpeg,*.png,*.gif -Recurse; ^
    foreach ($img in $images) { ^
        Write-Host ('优化图片: ' + $img.FullName); ^
        try { ^
            magick $img.FullName -strip -interlace Plane -quality 85%% $img.FullName; ^
            Write-Host ('已优化: ' + $img.Name) -ForegroundColor Green; ^
        } catch { ^
            Write-Host ('优化失败: ' + $img.Name + ' - ' + $_.Exception.Message) -ForegroundColor Red; ^
        } ^
    }^"
) else if "%optimize_choice%"=="3" (
    goto menu
)

echo.
echo 图片优化完成!
pause
goto menu

:rename_images
echo.
echo 批量重命名图片（移除中文和特殊字符）...
echo 1. 仅处理全局图片(source/img目录)
echo 2. 处理所有文章图片
echo 3. 返回上级菜单
set /p rename_choice=请选择操作 (1-3): 

if "%rename_choice%"=="1" (
    echo 正在处理全局图片...
    if not exist "source\img" mkdir "source\img"
    powershell -Command ^"^
    Get-ChildItem 'source/img' -File | ForEach-Object { ^
        $oldName = $_.Name; ^
        $newName = $oldName -replace '[^\x00-\x7F]+', '' -replace '[^a-zA-Z0-9.-]', '-'; ^
        if ($oldName -ne $newName) { ^
            try { ^
                Rename-Item $_.FullName -NewName $newName -Force; ^
                Write-Host ('已重命名: ' + $oldName + ' -> ' + $newName) -ForegroundColor Green; ^
            } catch { ^
                Write-Host ('重命名失败: ' + $oldName + ' - ' + $_.Exception.Message) -ForegroundColor Red; ^
            } ^
        } ^
    }^"
) else if "%rename_choice%"=="2" (
    echo 正在处理所有文章图片...
    powershell -Command ^"^
    Get-ChildItem 'source/_posts' -Directory | ForEach-Object { ^
        $postDir = $_.FullName; ^
        $postName = $_.Name; ^
        $images = Get-ChildItem $postDir -File -Include *.jpg,*.jpeg,*.png,*.gif -Recurse; ^
        $mdFile = Get-ChildItem 'source/_posts' -Filter ($postName + '.md'); ^
        $content = $null; ^
        if ($mdFile) { $content = Get-Content -Path $mdFile.FullName -Raw -Encoding UTF8; } ^
        foreach ($img in $images) { ^
            $oldName = $img.Name; ^
            $newName = $oldName -replace '[^\x00-\x7F]+', '' -replace '[^a-zA-Z0-9.-]', '-'; ^
            if ($oldName -ne $newName) { ^
                try { ^
                    $newPath = Join-Path $img.DirectoryName $newName; ^
                    Rename-Item $img.FullName -NewName $newName -Force; ^
                    Write-Host ('已重命名: ' + $oldName + ' -> ' + $newName) -ForegroundColor Green; ^
                    if ($content -and $content.Contains($oldName)) { ^
                        $content = $content -replace [regex]::Escape($oldName), $newName; ^
                        Set-Content -Path $mdFile.FullName -Value $content -Encoding UTF8; ^
                        Write-Host ('已更新文章中的引用: ' + $oldName + ' -> ' + $newName) -ForegroundColor Cyan; ^
                    } ^
                } catch { ^
                    Write-Host ('重命名失败: ' + $oldName + ' - ' + $_.Exception.Message) -ForegroundColor Red; ^
                } ^
            } ^
        } ^
    }^"
) else if "%rename_choice%"=="3" (
    goto menu
)

echo.
echo 图片重命名完成!
pause
goto menu

:import_clipboard
echo.
set /p post_title=请输入要添加图片的文章标题（不包含.md）: 
if not exist "source/_posts/%post_title%" (
    echo 创建文章图片目录...
    mkdir "source/_posts/%post_title%"
)

set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
set img_path=source/_posts/%post_title%/image_%timestamp%.png

echo 正在从剪贴板导入图片...
powershell -Command ^"^
Add-Type -AssemblyName System.Windows.Forms; ^
try { ^
    $img = [Windows.Forms.Clipboard]::GetImage(); ^
    if ($img) { ^
        $img.Save('%img_path%', [System.Drawing.Imaging.ImageFormat]::Png); ^
        echo '图片已保存：%img_path%'; ^
        echo '-----------------------------------'; ^
        echo '在Markdown中使用:'; ^
        echo '![描述](image_%timestamp%.png)'; ^
        echo '-----------------------------------'; ^
        echo '提示：'; ^
        echo '1. 将上面的代码复制到您的Markdown文章中'; ^
        echo '2. 将"描述"替换为您想要的图片描述'; ^
    } else { ^
        echo '剪贴板中没有图片！请先复制图片' -ForegroundColor Red; ^
    } ^
} catch { ^
    echo ('导入图片失败: ' + $_.Exception.Message) -ForegroundColor Red; ^
    echo '可能原因：'; ^
    echo '1. 剪贴板中没有有效图片'; ^
    echo '2. 没有足够的权限写入文件'; ^
    echo '3. 文件路径包含不支持的字符'; ^
}^"

echo.
pause
goto menu

:create_post_dir
echo.
echo ========= 创建文章图片目录 =========
echo 此功能用于为已存在的文章创建图片目录
echo.
set /p post_title=请输入文章标题（不包含.md）: 

if not exist "source/_posts/%post_title%.md" (
    echo 错误：文章 %post_title%.md 不存在！
    echo 请确认文章标题是否正确
    pause
    goto menu
)

if not exist "source/_posts/%post_title%" (
    echo 创建文章图片目录：source/_posts/%post_title%
    mkdir "source/_posts/%post_title%"
    echo 目录创建成功！
) else (
    echo 图片目录已存在：source/_posts/%post_title%
)

echo.
echo 您现在可以：
echo 1. 手动将图片文件复制到此目录
echo 2. 使用选项4从剪贴板导入图片
echo 3. 在文章中使用 ![描述](图片名.jpg) 引用图片
echo.
pause
goto menu

:end
echo.
echo 感谢使用！
pause 