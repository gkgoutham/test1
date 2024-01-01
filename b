<!-- src/app/login/login.component.html -->
<div class="container-fluid">
  <div class="row">
    <div class="col-md-6 login-image">
      <!-- Background Image -->
    </div>
    <div class="col-md-6 login-form">
      <div class="d-flex align-items-center justify-content-center h-100">
        <!-- SSO Login Icon -->
        <div class="text-center">
          <img class="mb-4" src="path/to/sso-icon.png" alt="SSO Icon" width="72" height="72">
          <h1 class="h3 mb-3 font-weight-normal">Login using SSO</h1>
        </div>

        <!-- Username and Password Fields (Shown only when passwordLoginDisabled is false) -->
        <form *ngIf="!passwordLoginDisabled">
          <div class="form-label-group">
            <input type="text" id="username" class="form-control" placeholder="Username" required>
            <label for="username">Username</label>
          </div>

          <div class="form-label-group">
            <input type="password" id="password" class="form-control" placeholder="Password">
            <label for="password">Password</label>
          </div>

          <!-- Login Button -->
          <button class="btn btn-lg btn-primary btn-block" type="submit">Login</button>
        </form>
      </div>

      <!-- Enable/Disable Password Login Toggle -->
      <div class="custom-control custom-checkbox mt-3">
        <input type="checkbox" class="custom-control-input" id="togglePasswordLogin" [(ngModel)]="passwordLoginDisabled">
        <label class="custom-control-label" for="togglePasswordLogin">Enable Password Login</label>
      </div>
    </div>
  </div>
</div>

/* src/app/login/login.component.css */
.login-image {
  background: url('path/to/background-image.jpg') center center / cover no-repeat;
  height: 100vh;
}

.login-form {
  background-color: #f8f9fa;
  padding: 40px;
  height: 100vh;
}

.form-label-group {
  position: relative;
  margin-bottom: 1rem;
}

.form-label-group input {
  height: 3rem;
}

.custom-control-input {
  height: 1.5rem;
  width: 1.5rem;
}
