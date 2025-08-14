(function(){
  const FILES_BASE="/static/data/";
  const ORDER_FUNC=["Seguridad Pública","Servicios Públicos","Defensa","Vivienda","Cultura","Salud","Educación","Protección Social","Asuntos Económicos","Medioambiente","Seguridad Pública +"];
  const ORDER_SUB =["Servicios de policía","Tribunales de justicia","Prisiones","Otro"];
  var sel=document.getElementById("sel-ds"), btn=document.getElementById("btn-plot"), meta=document.getElementById("meta"), plot=document.getElementById("plot");
  function humanRange(a){var ys=a.filter(Number.isFinite);return ys.length?Math.min.apply(null,ys)+"–"+Math.max.apply(null,ys):"—";}
  function isPctFile(n){return /pct_pib|pct_gt|pct_gasto/i.test(n)}; function isSubFile(n){return /subsec/i.test(n)}
  function getYearKey(cols){for(const k of ["Year","Año","anio","year"]) if(cols.includes(k)) return k; return cols[0]}
  function tidyToWide(data,yearKey){if(!data.length) return data; const cols=Object.keys(data[0]);
    const valueKey=cols.find(c=>/^value$/i.test(c)||/^valor$/i.test(c));
    const labelKey=cols.find(c=>/subsec|func/i.test(c));
    if(!valueKey||!labelKey||!yearKey) return data;
    const byYear=new Map();
    for(const r of data){const y=r[yearKey]; if(y==null) continue; if(!byYear.has(y)) byYear.set(y,{[yearKey]:y}); byYear.get(y)[r[labelKey]]=r[valueKey]}
    return Array.from(byYear.values()).sort((a,b)=>(a[yearKey]||0)-(b[yearKey]||0))
  }
  async function draw(){
    const file=sel.value, url=FILES_BASE+file; let data=[];
    try{ const res=await fetch(url,{cache:"no-store"}); data=await res.json(); }
    catch(e){ console.error("Error",url,e); Plotly.newPlot(plot,[],{title:"No se pudo leer el dataset."}); if(meta) meta.textContent=""; return }
    if(!Array.isArray(data)||!data.length){ Plotly.newPlot(plot,[],{title:"Dataset vacío"}); if(meta) meta.textContent=""; return }
    let cols=Object.keys(data[0]), yearKey=getYearKey(cols);
    if(cols.some(c=>/subsec|func/i.test(c)) && cols.some(c=>/^value$|^valor$/i.test(c))){ data=tidyToWide(data,yearKey); cols=Object.keys(data[0]||{}); yearKey=getYearKey(cols) }
    const series=cols.filter(c=>c!==yearKey);
    const orderList=isSubFile(file)?ORDER_SUB:ORDER_FUNC;
    const ordered=orderList.filter(n=>series.includes(n)).concat(series.filter(s=>!ORDER_FUNC.includes(s)&&!ORDER_SUB.includes(s)));
    const x=data.map(d=>d[yearKey]);
    const traces=ordered.map(name=>({x, y:data.map(d=>{const v=d[name]; return (v==null||Number.isNaN(v))?null:v}), name, mode:'lines+markers', type:'scatter', connectgaps:false}));
    const fmt=isPctFile(file)?'%{y:.2f}%<extra>%{fullData.name}</extra>':'%{y:,.0f}<extra>%{fullData.name}</extra>';
    traces.forEach(t=>t.hovertemplate=fmt);
    const titleMap={
      "viz_sp_pct_pib_incl_ps.json":"Funciones COFOG – % del PIB (incluye PS)",
      "viz_sp_pct_pib_excl_ps.json":"Funciones COFOG – % del PIB (excluye PS)",
      "viz_sp_pct_gt_incl_ps.json":"Funciones COFOG – % del Gasto Total (incluye PS)",
      "viz_sp_pct_gt_excl_ps.json":"Funciones COFOG – % del Gasto Total (excluye PS)",
      "viz_sp_pesos22_excl_ps.json":"Funciones COFOG – Pesos 2024 (excluye PS)",
      "viz_sp_subsec_pct_pib.json":"Subsectores de Seguridad – % del PIB",
      "viz_sp_subsec_pct_gt_sp.json":"Subsectores de Seguridad – % del gasto en Seguridad",
      "viz_sp_subsec_pesos22.json":"Subsectores de Seguridad – Pesos 2024"
    };
    const layout={title:{text:titleMap[file]||"Gráfico"}, margin:{t:50,r:10,b:80,l:60}, height:Math.max(560,Math.round(window.innerHeight*0.70)),
      xaxis:{title:"Año",tickmode:"linear",showspikes:true,spikemode:"across",spikesnap:"cursor",spikethickness:1},
      yaxis:isPctFile(file)?{title:"Porcentaje",ticksuffix:"%",tickformat:".2f",rangemode:"tozero",showspikes:true}:{title:"Pesos 2024",tickformat:"~s",rangemode:"tozero",showspikes:true},
      legend:{orientation:"h",y:-0.22,itemclick:"toggle",itemdoubleclick:"toggleothers"}, hovermode:"x", uirevision:file };
    const config={displaylogo:false,responsive:true,scrollZoom:true,modeBarButtonsToAdd:["toggleSpikelines"]};
    layout.hoverlabel=Object.assign({namelength:24},layout.hoverlabel||{});
    Plotly.newPlot(plot,traces,layout,config);
    if(meta){ const ys=x.filter(Number.isFinite); meta.textContent="Años disponibles en este dataset: "+(ys.length?(Math.min.apply(null,ys)+"–"+Math.max.apply(null,ys)):"—")+". Tip: doble clic en la leyenda aísla una serie." }
  }
  if(btn) btn.addEventListener("click",draw);
  window.addEventListener("resize",()=>Plotly.relayout(plot,{height:Math.max(560,Math.round(window.innerHeight*0.70))}));
  document.addEventListener("DOMContentLoaded",draw);
  (function(){ const tabs=document.querySelectorAll('#tabs button'); const secs={dipres:'#tab-dipres',enusc:'#tab-enusc',cead:'#tab-cead'};
    function show(which){ for(const [k,sel] of Object.entries(secs)){ const on=(k===which); const el=document.querySelector(sel); if(el) el.style.display=on?'':'none'; const b=document.querySelector('#tabs [data-tab="'+k+'"]'); if(b) b.className=on?'btn btn-primary':'btn btn-secondary'; }
      if(which==='dipres' && window.Plotly && document.getElementById('plot') && document.getElementById('plot').data) Plotly.Plots.resize(document.getElementById('plot'));
    }
    tabs.forEach(b=>b.addEventListener('click',()=>show(b.dataset.tab))); show('dipres');
  })();
})();
