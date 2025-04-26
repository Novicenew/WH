document.addEventListener('DOMContentLoaded', () => {
  // 创建鼠标跟随效果
  const cursor = document.createElement('div');
  cursor.className = 'cursor-effect';
  document.body.appendChild(cursor);

  // 鼠标移动事件
  document.addEventListener('mousemove', (e) => {
    cursor.style.left = e.clientX + 'px';
    cursor.style.top = e.clientY + 'px';
  });

  // 点击效果
  document.addEventListener('click', (e) => {
    const ripple = document.createElement('div');
    ripple.className = 'cursor-effect';
    ripple.style.left = e.clientX + 'px';
    ripple.style.top = e.clientY + 'px';
    document.body.appendChild(ripple);

    ripple.style.animation = 'ripple-effect 1s linear';
    ripple.addEventListener('animationend', () => {
      ripple.remove();
    });
  });
}); 