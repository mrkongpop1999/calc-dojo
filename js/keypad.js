/* On-screen number pad for touch devices. The phone keyboard hides half the screen and the iOS
   decimal pad has no Enter key, so answers could not be submitted. This pad has digits, a decimal
   point and backspace; the page's own "ตอบ / ตรวจ" button submits. Hardware keyboards still work. */
const Keypad={
  coarse:()=>{try{return matchMedia('(pointer:coarse)').matches}catch(e){return false}},
  /* attach(input, host): returns true when the pad is shown */
  attach(input,host){
    if(!Keypad.coarse()||!input||!host)return false;
    input.setAttribute('inputmode','none');
    host.innerHTML=`<div class="kp" role="group" aria-label="แป้นตัวเลข">${['7','8','9','4','5','6','1','2','3','.','0','del'].map(k=>
      `<button type="button" class="k${k==='del'?' del':''}" data-k="${k}" ${k==='del'?'aria-label="ลบ"':''}>${k==='del'?'<svg viewBox="0 0 24 24" width="26" height="26" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 5H9l-6 7 6 7h12z"/><path d="m13 9 4 6M17 9l-4 6"/></svg>':k}</button>`).join('')}</div>`;
    const press=k=>{
      if(k==='del')input.value=input.value.slice(0,-1);
      else if(k==='.'){if(!input.value.includes('.'))input.value=(input.value||'0')+'.'}
      else if(input.value.length<12)input.value+=k;
      input.dispatchEvent(new Event('input',{bubbles:true}))};
    host.addEventListener('pointerdown',e=>{const b=e.target.closest('.k');if(!b)return;e.preventDefault();press(b.dataset.k)});
    host.addEventListener('click',e=>{if(e.target.closest('.k'))e.preventDefault()});
    /* hold ⌫ to clear */
    let t=null;host.addEventListener('pointerdown',e=>{const b=e.target.closest('.del');if(!b)return;clearTimeout(t);t=setTimeout(()=>{input.value='';input.dispatchEvent(new Event('input',{bubbles:true}))},550)});
    ['pointerup','pointercancel','pointerleave'].forEach(ev=>host.addEventListener(ev,()=>clearTimeout(t)));
    return true}
};
