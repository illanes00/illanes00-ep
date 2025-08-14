//  Incrementar vistas al cargar la página de detalle
document.addEventListener("DOMContentLoaded", () => {
    const detail = document.querySelector("[data-post-id]");
    if (detail){
      fetch(`/blog/${detail.dataset.postId}/view`, {method:"POST"});
    }
  
    //  Likes
    const likeBtn = document.getElementById("btn-like");
    if (likeBtn){
      likeBtn.addEventListener("click", () => {
        fetch(`/blog/${likeBtn.dataset.postId}/like`, {method:"POST"})
          .then(r=>r.json()).then(j=>{
            document.getElementById("like-count").textContent = j.likes;
            likeBtn.classList.toggle("liked");
          });
      });
    }
  });
  

document.addEventListener("DOMContentLoaded", () => {

    // --- tabla datasets -----------------------------------------------
    const tbl = document.getElementById("dataset-table");
    if (tbl){
      const url = tbl.dataset.api;          // viene del template
      fetch(url).then(r=>r.json()).then(data=>{
        $('#dataset-table').DataTable({
          data: data,
          // columnas se inyectan desde el template via data-columns JSON
          columns: JSON.parse(tbl.dataset.columns),
          pageLength: 25,
          dom: 'Bfrtip',
          buttons: ['csv', 'excel', 'colvis', 'pageLength'],
          language:{
            url:"https://cdn.datatables.net/plug-ins/1.13.7/i18n/es-ES.json"
          }
        });
      });
    }
  
  });