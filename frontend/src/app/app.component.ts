import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-root',
  imports: [CommonModule, FormsModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent  implements OnInit{
  id: number | null = null;

  title: string | null = null;
  description: string | null = null;
  
  posts: any[] = [];
  constructor(private http: HttpClient) {}

  ngOnInit(): void {
    this.fetchData()
  }

  fetchData(){
    this.http.get("/api/posts").subscribe((res:any)=>{
      this.posts = res.data;
    })
  }

  edit(id:number){
    this.http.get("/api/posts/" + id).subscribe((res:any)=>{
      this.id  = res.id;
      this.title  = res.title;
      this.description  = res.description;
    })
  }

  delete(id:number){
    this.http.delete("/api/posts/" + id).subscribe(res=>{
      this.fetchData()
      this.cancel()
    });
  }

  save(){
    let sub: any;
    let body : any = {
      title: this.title,
      description: this.description,
    }
    if(this.id){
      sub =  this.http.put("/api/posts/" + this.id, body);
    }else{
      sub =  this.http.post("/api/posts", body);
    }
    sub.subscribe((res:any)=>{
      this.fetchData()
      this.cancel()
    })
  }

  cancel(){
    this.id = this.title = this.description = null;
  }

}
