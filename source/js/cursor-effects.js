document.addEventListener('DOMContentLoaded', () => {
  // 创建鼠标跟随元素
  const cursor = document.createElement('div');
  cursor.className = 'cursor-effect';
  const cursorDot = document.createElement('div');
  cursorDot.className = 'cursor-dot';
  document.body.appendChild(cursor);
  document.body.appendChild(cursorDot);

  // 鼠标移动事件
  document.addEventListener('mousemove', (e) => {
    cursorDot.style.left = e.clientX + 'px';
    cursorDot.style.top = e.clientY + 'px';
    
    // 添加平滑跟随效果
    setTimeout(() => {
      cursor.style.left = e.clientX + 'px';
      cursor.style.top = e.clientY + 'px';
    }, 50);
  });

  // 鼠标点击效果
  document.addEventListener('click', (e) => {
    // 创建点击波纹
    const ripple = document.createElement('div');
    ripple.className = 'cursor-effect';
    ripple.style.left = e.clientX + 'px';
    ripple.style.top = e.clientY + 'px';
    ripple.style.animation = 'ripple 0.8s linear';
    document.body.appendChild(ripple);

    // 动画结束后移除元素
    ripple.addEventListener('animationend', () => {
      ripple.remove();
    });
  });

  // 鼠标悬停效果
  document.addEventListener('mouseover', (e) => {
    if (e.target.tagName.toLowerCase() === 'a' || e.target.tagName.toLowerCase() === 'button') {
      cursor.style.width = '60px';
      cursor.style.height = '60px';
      cursor.style.borderColor = 'rgba(255,255,255,1)';
    }
  });

  document.addEventListener('mouseout', (e) => {
    if (e.target.tagName.toLowerCase() === 'a' || e.target.tagName.toLowerCase() === 'button') {
      cursor.style.width = '40px';
      cursor.style.height = '40px';
      cursor.style.borderColor = 'rgba(255,255,255,0.8)';
    }
  });
}); 