(function(){
  const FILES_BASE="/static/data/";
  var sel=document.getElementById("sel-cead"), btn=document.getElementById("btn-plot-cead"), meta=document.getElementById("meta-cead"), plot=document.getElementById("plot-cead");
  function getYearKey(cols){for(const k of ["Year","Año","anio","year"]) if(cols.includes(k)) return k; return cols[0]}
  function tidyToWide(data,yk){if(!data.length) return data; const cols=Object.keys(data[0]);
    const valueKey=cols.find(c=>/^value$/i.test(c)||/^valor$/i.test(c)); const labelKey=cols.find(c=>/Delito/i.test(c));
    if(!valueKey||!labelKey||!yk) return data; const byYear={}; data.forEach(r=>{const y=r[yk]; if(y==null) return; byYear[y]||(byYear[y]={[yk]:y}); byYear[y][r[labelKey]]=r[valueKey]});
    return Object.values(byYear).sort((a,b)=>(a[yk]||0)-(b[yk]||0));
  }
  async function draw(){
    var file=(sel&&sel.value)?sel.value:"viz_cead_total.json", url=FILES_BASE+file, data=[];
    try{ const res=await fetch(url,{cache:"no-store"}); data=await res.json(); }
    catch(e){ console.error(e); Plotly.newPlot(plot,[],{title:"No se pudo leer el dataset CEAD."},{displaylogo:false}); if(meta) meta.textContent=""; return }
    if(!Array.isArray(data)||!data.length){ Plotly.newPlot(plot,[],{title:"Dataset CEAD vacío"},{displaylogo:false}); if(meta) meta.textContent=""; return }
    let cols=Object.keys(data[0]), yk=getYearKey(cols);
    if(cols.some(c=>/Delito/.test(c)) && cols.some(c=>/^value$|^valor$/i.test(c))){ data=tidyToWide(data,yk); cols=Object.keys(data[0]); yk=getYearKey(cols) }
    const series=cols.filter(c=>c!==yk); const x=data.map(d=>d[yk]);
    const traces=series.map(name=>({x, y:data.map(d=>{const v=d[name]; return (v==null||Number.isNaN(v))?null:v}), name, mode:'lines+markers', type:'scatter', connectgaps:false, hovertemplate:'%{y:,.0f}<extra>%{fullData.name}</extra>'}));
    var titleText="CEAD"; if(sel && sel.options && sel.selectedIndex>=0){ const opt=sel.options[sel.selectedIndex]; if(opt && opt.text) titleText=opt.text; }
    Plotly.newPlot(plot,traces,{title:{text:titleText},margin:{t:50,r:10,b:80,l:60},height:Math.max(520,Math.round(window.innerHeight*0.70)),xaxis:{title:"Año",tickmode:"linear",showspikes:true,spikemode:"across"},yaxis:{title:"Incidentes",tickformat:"~s",rangemode:"tozero",showspikes:true},legend:{orientation:"h",y:-0.22},hovermode:"x unified"},{displaylogo:false,responsive:true,scrollZoom:true});
    const ys=x.filter(Number.isFinite); if(meta) meta.textContent=ys.length?("Años: "+Math.min.apply(null,ys)+"–"+Math.max.apply(null,ys)):"";
  }
  if(btn) btn.addEventListener("click",draw);
  document.addEventListener("DOMContentLoaded",draw);
})();
